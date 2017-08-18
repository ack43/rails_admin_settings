if !window.rails_admin_settings or !window.rails_admin_settings.enum_loaded
  window.rails_admin_settings ||= {}
  window.rails_admin_settings.multiselect_dblclick = (selector)->
    left_selector = []
    right_selector = []
    selector.split(",").forEach (sel)->
      left_selector.push(sel + ' .ra-multiselect-left select option')
      right_selector.push(sel + ' .ra-multiselect-right select option')
    left_selector = left_selector.join(", ")
    right_selector = right_selector.join(", ")

    $(document).on 'dblclick', left_selector, (e)->
      $(e.currentTarget).closest('.ra-multiselect').find('.ra-multiselect-center .ra-multiselect-item-add').click()
    $(document).on 'dblclick', right_selector, (e)->
      $(e.currentTarget).closest('.ra-multiselect').find('.ra-multiselect-center .ra-multiselect-item-remove').click()
  window.rails_admin_settings.multiselect_dblclick("#rails_admin_settings_setting_raw_array_field select.rails_admin_settings_enum + .ra-multiselect")

  window.rails_admin_settings.set_enum_with_custom = () ->
    $('#rails_admin_settings_setting_raw_field .ra-filtering-select-input, #rails_admin_settings_setting_raw_array_field .ra-filtering-select-input').autocomplete(
      search: (e, ui)->
        if e.currentTarget
          $(e.currentTarget).closest(".controls").find("select.rails_admin_settings_enum option:first").val(e.currentTarget.value).text(e.currentTarget.value)
          _src = $(e.currentTarget).closest(".controls").find("select.rails_admin_settings_enum option").map( ->
            { label: $(this).text(), value: $(this).text() }
          ).toArray();
          $(e.currentTarget).closest(".controls").find("select").val(e.currentTarget.value).data('raFilteringSelect').options.source = _src
    )
    custom_enum_selector = '#rails_admin_settings_setting_raw_field .custom_enum ~ .ra-multiselect .ra-multiselect-search'
    multiple_custom_enum_selector = '#rails_admin_settings_setting_raw_array_field .multiple_custom_enum ~ .ra-multiselect .ra-multiselect-search'
    $([custom_enum_selector, multiple_custom_enum_selector].join(", ")).on('keydown', (e)->
      return true if e.ctrlKey
      if e.which == 13
        e.preventDefault()
        me = $(e.currentTarget)
        new_item_text = me.val().trim()
        return false if new_item_text.length == 0
        parent_block = me.closest(".ra-multiselect")
        left_collection   = parent_block.find(".ra-multiselect-left .ra-multiselect-collection")
        found_item = null
        left_collection.find("option").each ->
          found_item = $(this) if this.value == new_item_text
          return !found_item
        unless found_item
          if parent_block.siblings("[data-filteringmultiselect][data-unique=true]").length > 0
            right_collection  = parent_block.find(".ra-multiselect-right .ra-multiselect-selection")
            right_collection.find("option").each ->
              found_item = $(this) if this.value == new_item_text
              return !found_item
            return false if found_item
          left_collection.append(found_item = $('<option></option>').attr('value', new_item_text).attr('title', new_item_text).text(new_item_text))
        found_item.prop('selected', true).trigger('dblclick')

        return false
    ).each ->
      onclick = '$(this).siblings(".ra-multiselect-search").trigger($.Event("keydown", {which: 13}));return false;'
      # onclick = '$(this).siblings(".ra-multiselect-search").keydown({which: 13});return false;'
      $(this).after("<a class='rails_admin_settings_enum_with_custom_type_add_button' href='#' onclick='" + onclick + "' title='Добавить'>+</a>")


  $(document).on "change", "#rails_admin_settings_setting_raw_field :input, #rails_admin_settings_setting_raw_array_field :input", (e)->
    field_block = $(e.currentTarget).closest(".controls")
    hidden_field = field_block.find("[type='hidden']")
    if field_block.find(":input:not([type='hidden'])").serializeArray().length == 0
      hidden_field.prop('name', hidden_field.data('name')) if hidden_field.data('name')
    else
      hidden_field.data('name', hidden_field.prop('name')) if hidden_field.prop('name')
      hidden_field.prop('name', '')


  $(document).on 'rails_admin.dom_ready', ->
    window.rails_admin_settings.set_enum_with_custom()
    $(".rails_admin_settings_enum :input[type='hidden']").trigger('change')

window.rails_admin_settings ||= {}
window.rails_admin_settings.enum_loaded = true
