if !window.rails_admin_settings or !window.rails_admin_settings.hash_loaded
  $(document).on "click", "#edit_rails_admin_settings_setting .raw_hash_field .rails_admin_settings_hash_element_add_link", (e)->
    e.preventDefault()
    link = $(e.currentTarget)
    link_parent = link.parent()
    link_parent.before(link.data('template'))
    $("#edit_rails_admin_settings_setting .raw_hash_field .rails_admin_settings_hash_element_block input:last").blur()
    return false


  $(document).on 'click', '#edit_rails_admin_settings_setting .raw_hash_field .rails_admin_settings_hash_element_delete_link', (e)->
    e.preventDefault()
    $(e.currentTarget).parent().remove()
    return false

  $(document).on 'blur', '#edit_rails_admin_settings_setting .raw_hash_field .rails_admin_settings_hash_element_key_field', (e)->
    e.preventDefault()
    input = $(e.currentTarget).siblings('input')
    old_id    = input.prop('id')
    old_name  = input.prop('name')
    new_name = e.currentTarget.value
    reg_for_id = /\[[^\[\]]+\]$/i
    reg_for_name = /\[[^\[\]]+\]\]$/i
    input.prop('id',    old_id.replace(reg_for_id, "[" + new_name + "]"))
    input.prop('name',  old_name.replace(reg_for_name, "[" + new_name + "]]"))
    return false


  $(document).on 'blur', '#edit_rails_admin_settings_setting .raw_hash_field .rails_admin_settings_hash_element_block input', (e)->
    fields_block = $(e.currentTarget).closest(".controls")
    fields_block.find('.value_field').each ->
      $(this).parent().removeClass('duplicate')
      fields_block.find('.value_field').not($(this)).filter("[name='" + this.name + "']").parent().addClass('duplicate')


window.rails_admin_settings ||= {}
window.rails_admin_settings.hash_loaded = true
