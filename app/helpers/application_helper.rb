module ApplicationHelper

  def present_snippets args
    val = args[:value]
    return unless val.present?
    ('...' + val.join('...<br/>...')).html_safe
  end
end
