<?php if (!defined('FW')) die('Forbidden');

/** @internal */
function seosight_forms_fw_ext_forms_include_custom_builder_items() {
    require get_template_directory() . '/framework-customizations/extensions/forms/includes/builder-items/recaptchav3/class-fw-option-type-form-builder-item-recaptchav3.php';
}
add_action('fw_option_type_form_builder_init', 'seosight_forms_fw_ext_forms_include_custom_builder_items');