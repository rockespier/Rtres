<?php if ( ! defined( 'ABSPATH' ) ) {
	die;
} // Cannot access pages directly.
// ===============================================================================================
// -----------------------------------------------------------------------------------------------
// NAVIGATION OPTIONS
// -----------------------------------------------------------------------------------------------
// ===============================================================================================

// Control core classes for avoid errors
if( class_exists( 'CSF' ) ) {
    $prefix_nav = 'seosight_menu_options';
    CSF::createNavMenuOptions( $prefix_nav, array(
        'data_type' => 'serialize', // The type of the database save options. `serialize` or `unserialize`
        'class' => 'seosight-menu-mega-options',
    ) );

    CSF::createSection( $prefix_nav, array(
        'title'  => esc_html__( 'Mega menu', 'seosight' ),
        'fields' => array(
            array(
				'id'    => 'megamenu-enable',
				'type'  => 'checkbox',
				'title' => esc_html__( 'Use as Mega Menu', 'seosight' ),
                'default' => false,
                'inline' => true,
                'class' => 'seosight-menu-row-field seosight-menu-mega-enable'
			),
            array(
				'id' => 'background-image',
				'type' => 'upload',
				'library' => 'image',
				'title' => esc_html__( 'Background Image', 'seosight' ),
                'dependency' => array( 'megamenu-enable', '==', 'true' ),
                'class' => 'seosight-menu-row-field'
            ),
            array(
				'id'    => 'hide-title',
				'type'  => 'switcher',
                'title' => esc_html__( 'Hide title', 'seosight' ),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'text_width' => 60,
                'default' => false,
                'class' => 'seosight-menu-column-field hide-title'
            ),
            array(
				'id'    => 'new-row',
				'type'  => 'switcher',
                'title' => esc_html__( 'This column should start a new row', 'seosight' ),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'text_width' => 60,
                'default' => false,
                'class' => 'seosight-menu-column-field'
            ),
            array(
				'id'    => 'title_column_item',
				'type'  => 'switcher',
                'title' => esc_html__( 'Column title', 'seosight' ),
                'subtitle'  => esc_html__('Use column item as column title', 'seosight'),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'text_width' => 60,
                'default' => false,
                'class' => 'seosight-menu-column-field'
            ),
        )
    ));
}