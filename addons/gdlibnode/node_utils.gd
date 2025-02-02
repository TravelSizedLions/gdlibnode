@tool
class_name N

static func find(type, name: String = ""):
  return N.get_child(TreeAccess.root, type, name)

static func get_ancestor(node: Node, type, name: String = ""):
  if not node:
    return

  if __is_correct_node(node, type, name):
    return node

  var ancestor = node.get_parent()
  while ancestor and not __is_correct_node(ancestor, type, name):
    ancestor = ancestor.get_parent()

  return ancestor

static func get_immediate_child(node: Node, type):
  if not node: 
    return null

  if is_instance_of(node, type):
    return node
  
  for child in node.get_children():
    if is_instance_of(node, type):
      return node

  return null

static func get_child(node: Node, type, name: String = ""):
  if not node:
    return null
  
  if __is_correct_node(node, type, name):
    return node
  
  for child in node.get_children():
    var result = N.get_child(child, type, name)
    if result:
      return result

  return null

## Gets all children of a specific type, including the node in question if it's the correct type.
static func get_all_children(node: Node, type, include_self: bool = true):
  if not node:
    return []
  
  var result = []

  if include_self and __is_correct_node(node, type):
    result.append(node)

  for child in node.get_children():
    result += N.get_all_children(child, type, true)

  return result

static func __is_correct_node(node: Node, type, name: String = ""):
  return is_instance_of(node, type) and (not name or node.name == name)

static func create(script: GDScript, parent = null, owner = null, name_prefix: String = ""):
  var node = Node.new()
  node.set_script(script)
  return __create(node, parent, owner, name_prefix)

static func create_native(nativeClass, parent: Node = null, owner: Node = null, name_prefix: String = ""):
  return __create(nativeClass.new(), parent, owner, name_prefix)

static func create_scene(scene: PackedScene, parent: Node = null, owner: Node = null, name_prefix: String = ""):
  if not scene:
    push_warning('Got a null scene!')
    print_stack()
    return
  return __create(scene.instantiate(), parent, owner, name_prefix)

static func __create(node: Node,  parent: Node = null, owner: Node = null, name_prefix: String = ""):
  if not name_prefix:
    name_prefix = "node"

  node.set_name("%s_%s" % [name_prefix, node.get_instance_id()])

  if owner:
    node.connect('tree_entered', (func(): node.set_owner(owner)))
  elif parent:
    node.connect('tree_entered', (func(): node.set_owner(parent)))
  else:
    node.connect('tree_entered', (func(): node.set_owner(TreeAccess.root)))
  
  if parent:
    parent.add_child(node)
  else:
    TreeAccess.root.add_child(node)

  return node

static func clear_signal(sig: Signal):
  for connection in sig.get_connections():
    sig.disconnect(connection.callable)

static func extends_from(script: Script, expected_base: Script):
  if not script or not expected_base:
    return false

  var base = script.get_base_script()
  if base == Object && expected_base != Object:
    return false
  
  if base == expected_base:
    return true

  return extends_from(base, expected_base)

static func is_inside(position: Vector2, control) -> bool:
  if not control:
    return false
  
  var rel_pos = position - control.global_position
  return (rel_pos.x >= 0
    and rel_pos.y >= 0
    and rel_pos.x <= control.size.x
    and rel_pos.y <= control.size.y)
