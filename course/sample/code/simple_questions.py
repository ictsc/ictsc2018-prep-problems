# -*- coding: utf-8 -*-

from __future__ import division

__copyright__ = "Copyright (C) 2014 Andreas Kloeckner"

__license__ = """
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

from course.validation import ValidationError
from course.page import PageBase, AnswerFeedback, markup_to_html
import django.forms as forms
from relate.utils import StyledForm


# {{{ text question

class TextAnswerForm(StyledForm):
    answer = forms.CharField(required=True)

    def __init__(self, *args, **kwargs):
        super(TextAnswerForm, self).__init__(*args, **kwargs)

        self.fields["answer"].widget.attrs["autofocus"] = None


class MyTextQuestion(PageBase):
    def __init__(self, vctx, location, page_desc):
        super(MyTextQuestion, self).__init__(vctx, location, page_desc)

        if len(page_desc.answers) == 0:
            raise ValidationError("%s: at least one answer must be provided"
                    % location)

    def required_attrs(self):
        return super(MyTextQuestion, self).required_attrs() + (
            ("title", str),
            ("prompt", "markup"),
            ("answers", list),
            )

    def title(self, page_context, page_data):
        return self.page_desc.title

    def body(self, page_context, page_data):
        return markup_to_html(page_context, self.page_desc.prompt)

    def expects_answer(self):
        return True

    def max_points(self, page_data):
        return 1

    def make_form(self, page_context, page_data,
            answer_data, answer_is_final):
        if answer_data is not None:
            answer = {"answer": answer_data["answer"]}
            form = TextAnswerForm(answer)
        else:
            answer = None
            form = TextAnswerForm()

        if answer_is_final:
            form.fields['answer'].widget.attrs['readonly'] = True

        return form

    def post_form(self, page_context, page_data, post_data, files_data):
        return TextAnswerForm(post_data, files_data)

    def answer_data(self, page_context, page_data, form, files_data):
        return {"answer": form.cleaned_data["answer"].strip()}

    def grade(self, page_context, page_data, answer_data, grade_data):
        correctness = 0

        if answer_data is None:
            return AnswerFeedback(correctness=0,
                    feedback="No answer provided.")

        answer = answer_data["answer"]

        for correct_answer in self.page_desc.answers:
            if correct_answer == answer:
                correctness = 1
                break

        return AnswerFeedback(correctness=correctness)

    def correct_answer(self, page_context, page_data, answer_data, grade_data):
        return "A correct answer is: '%s'." % self.page_desc.answers[0]

    def normalized_answer(self, page_context, page_data, answer_data):
        if answer_data is None:
            return None

        from django.utils.html import escape
        return escape(answer_data["answer"])

# }}}
