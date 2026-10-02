<?php if (!defined('FW')) die('Forbidden');

// MegaMenu column options
// MegaMenu row options
$options = array(
	'title_column_item' => array(
		'type'  => 'switch',
		'value' => 'no',
		'label' => esc_html__('Column title', 'seosight'),
		'desc'  => esc_html__('Use column item as column title', 'seosight'),
		'left-choice' => array(
			'value' => 'no',
			'label' => esc_html__('No', 'seosight'),
		),
		'right-choice' => array(
			'value' => 'yes',
			'label' => esc_html__('Yes', 'seosight'),
		),
	)
);