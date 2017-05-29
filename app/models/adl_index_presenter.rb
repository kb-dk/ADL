class AdlIndexPresenter < Blacklight::IndexPresenter
  def label(field_or_string_or_proc, opts = {})
    type = @document.first(:cat_ssi).to_s
    title = 'Ingen titel'
    if (type == 'author')
      title = @document.first(:inverted_name_title_ssi)
    else
      title = @document.first(:work_title_tesim).to_s
    end
    title
  end
end