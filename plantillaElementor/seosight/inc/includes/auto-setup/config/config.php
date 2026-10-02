<?php if ( ! defined( 'ABSPATH' ) ) {
	die( 'Direct access forbidden.' );
}
return array(
	/**
	 * Array for demos
	 */
	'demos'              => array(
		'seosight-elementor'    => array(
			array(
				'name'         => esc_attr__( 'Elementor', 'seosight' ),
				'slug'         => 'elementor',
			),
			array(
				'name'         => esc_attr__( 'Elementor Seosight Widgets', 'seosight' ),
				'slug'         => 'elementor-seosight',
				'source'       => 'http://up.crumina.net/plugins/elementor-seosight.zip', // The plugin source
			),
			array(
				'name'         => esc_attr__( 'Portfolio KIT', 'seosight' ),
				'slug'         => 'portfolio-kit',
				'source'       => 'http://up.crumina.net/plugins/portfolio-kit.zip',
				'required'     => false,
				'version'      => '1.1',
			),
			array(
				'name'         => 'Mailchimp for WordPress',
				'slug'         => 'mailchimp-for-wp',
			),
			array(
				'name' => 'WooCommerce',
				'slug' => 'woocommerce',
			),
		),
		'seosight-kingcomposer'    => array(
			array(
				'name'         => esc_attr__( 'King Composer', 'seosight' ),
				'slug'         => 'kingcomposer',
				'source'       => 'http://up.crumina.net/plugins/kingcomposer.zip',
			),
			array(
				'name'         => esc_attr__( 'Frontend Editor', 'seosight' ),
				'slug'         => 'kc_pro',
				'source'       => 'http://kingcomposer.com/downloads/kc_pro.zip', // The plugin source
			),
			array(
				'name'         => esc_attr__( 'KingComposer Seosight', 'seosight' ),
				'slug'         => 'kingcomposer-seosigh',
				'source'       => 'http://up.crumina.net/plugins/kingcomposer-seosight.zip',
			),
			array(
				'name'         => esc_attr__( 'Portfolio KIT', 'seosight' ),
				'slug'         => 'portfolio-kit',
				'source'       => 'http://up.crumina.net/plugins/portfolio-kit.zip',
				'required'     => false,
				'version'      => '1.1',
			),
			array(
				'name'         => 'Mailchimp for WordPress',
				'slug'         => 'mailchimp-for-wp',
			),
			array(
				'name' => 'WooCommerce',
				'slug' => 'woocommerce',
			),
		),
	),
	'plugins'            => array(),
	'theme_id'           => 'seosight',
	'child_theme_source' => 'http://up.crumina.net/demo-data/seosight/seosight-child.zip',
	'has_demo_content'   => true
);
