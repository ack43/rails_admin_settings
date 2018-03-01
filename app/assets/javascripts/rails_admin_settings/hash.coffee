if !window.rails_admin_settings or !window.rails_admin_settings.hash_loaded
  separate_form_selector  = "#edit_rails_admin_settings_setting .raw_hash_field .rails_admin_settings_hash_element_add_link"
  inline_form_selector    = ".rails_admin_settings_inline_form .raw_hash_field .rails_admin_settings_hash_element_add_link"
  $(document).on "click", separate_form_selector + ", " + inline_form_selector, (e)->
    e.preventDefault()
    link = $(e.currentTarget)
    link_parent = link.parent()
    link_parent.before(link.data('template'))
    $("#edit_rails_admin_settings_setting .raw_hash_field .rails_admin_settings_hash_element_block input:last").blur()
    return false


  separate_form_selector  = "#edit_rails_admin_settings_setting .raw_hash_field .rails_admin_settings_hash_element_delete_link"
  inline_form_selector    = ".rails_admin_settings_inline_form .raw_hash_field .rails_admin_settings_hash_element_delete_link"
  $(document).on 'click', separate_form_selector + ", " + inline_form_selector, (e)->
    e.preventDefault()
    $(e.currentTarget).parent().remove()
    return false

  separate_form_selector  = "#edit_rails_admin_settings_setting .raw_hash_field .rails_admin_settings_hash_element_key_field"
  inline_form_selector    = ".rails_admin_settings_inline_form .raw_hash_field .rails_admin_settings_hash_element_key_field"
  $(document).on 'blur', separate_form_selector + ", " + inline_form_selector, (e)->
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


  separate_form_selector  = "#edit_rails_admin_settings_setting .raw_hash_field .rails_admin_settings_hash_element_block input"
  inline_form_selector    = ".rails_admin_settings_inline_form .raw_hash_field .rails_admin_settings_hash_element_block input"
  $(document).on 'blur', separate_form_selector + ", " + inline_form_selector, (e)->
    fields_block = $(e.currentTarget).closest(".controls")
    fields_block.find('.value_field').each ->
      $(this).parent().removeClass('duplicate')
      fields_block.find('.value_field').not($(this)).filter("[name='" + this.name + "']").parent().addClass('duplicate')


window.rails_admin_settings ||= {}
window.rails_admin_settings.hash_loaded = true
