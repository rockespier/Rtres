<?php if (!defined('FW')) die('Forbidden');
/**
 * @var string $label
 * @var array $item
 * @var array $attr
 */
?>
<div class="<?php echo esc_attr(fw_ext_builder_get_item_width('form-builder', $item['width'] .'/frontend_class')) ?>">
	<div class="field-recaptcha">
        <label><?php echo fw_htmlspecialchars($item['options']['label']) ?></label>
        <input class="register-captcha-v3-token simple-input" type="hidden" name="token">
	</div>
</div>