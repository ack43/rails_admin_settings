if !window.rails_admin_settings or !window.rails_admin_settings.array_loaded
  $(document).on "click", "#edit_rails_admin_settings_setting .raw_array_field .rails_admin_settings_array_element_add_link", (e)->
    e.preventDefault()
    link = $(e.currentTarget)
    link_parent = link.parent()
    link_parent.before(link.data('template'))
    link_parent.prev().find('input:first').focus().select().trigger('change')
    return false


  $(document).on 'click', '#edit_rails_admin_settings_setting .raw_array_field .rails_admin_settings_array_element_delete_link', (e)->
    e.preventDefault()
    hidden_field = $(e.currentTarget).closest(".raw_array_field").find("[type='hidden']")
    $(e.currentTarget).parent().remove()
    hidden_field.trigger('change')
    return false


  $(document).on 'click', '#edit_rails_admin_settings_setting .raw_array_field .rails_admin_settings_array_element_move_link', (e)->
    e.preventDefault()
    link = $(e.currentTarget)
    array_element_block = link.parent()
    if link.hasClass("up")
      prev = array_element_block.prev(".rails_admin_settings_array_element_block")
      array_element_block.insertBefore(prev) if prev.length > 0
    if link.hasClass("down")
      next = array_element_block.next(".rails_admin_settings_array_element_block")
      array_element_block.insertAfter(next) if next.length > 0
    return false



  $(document).on "change", "#edit_rails_admin_settings_setting .raw_array_field :input", (e)->
    field_block = $(e.currentTarget).closest(".raw_array_field")
    hidden_field = field_block.find("[type='hidden']")
    if field_block.find(":input:not([type='hidden'])").serializeArray().length == 0
      hidden_field.prop('name', hidden_field.data('name')) if hidden_field.data('name')
    else
      hidden_field.data('name', hidden_field.prop('name')) if hidden_field.prop('name')
      hidden_field.prop('name', '')


  $(document).on "rails_admin.dom_ready", (e)->
    $("#edit_rails_admin_settings_setting .raw_array_field").find(":input[type='hidden']").trigger('change')


window.rails_admin_settings ||= {}
window.rails_admin_settings.array_loaded = true
