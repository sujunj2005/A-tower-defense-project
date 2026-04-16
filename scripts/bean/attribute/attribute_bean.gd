class_name AttributeBean
extends Resource

@export var attribute_id: String = ""
@export var display_name: String = ""
@export var icon: String = ""

static func from_dict(attr_id: String, data: Dictionary) -> AttributeBean:
	var bean := AttributeBean.new()
	bean.attribute_id = attr_id
	bean.display_name = data.get("display_name", attr_id)
	bean.icon = data.get("icon", "")
	return bean

func get_display_with_icon() -> String:
	if icon != "":
		return "%s %s" % [icon, tr(display_name)]
	return tr(display_name)
