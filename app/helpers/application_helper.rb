module ApplicationHelper
  def editable_field(record, field)
    value = record.send(field)
    tag.span(value, class: "editable", data: { id: record.id, field: field })
  end
end
