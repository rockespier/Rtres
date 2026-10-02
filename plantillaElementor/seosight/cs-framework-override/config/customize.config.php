<?php if ( ! defined( 'ABSPATH' ) ) {
	die;
}

// Control core classes for avoid errors
if( class_exists( 'CSF' ) ) {
	$customize_prefix = 'seosight_customize_options';

	require_once plugin_dir_path( __FILE__ ) .'config-fields-class.php';
	$options = new SeosightThemeOptionsFields();

	// Create customize options
	CSF::createCustomizeOptions( $customize_prefix, array(
		'database' => 'theme_mod'
	) );

	// Typography section
	CSF::createSection( $customize_prefix, array(
		'id' => 'panel_typography',
		'title'  => esc_html__( 'Typography', 'seosight' ),
		'priority' => 122,
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_typography',
		'title'  => esc_html__( 'Body font', 'seosight' ),
		'fields' => array(
			array(
				'id'        => 'typography_body',
				'type'      => 'typography',
				'title'      => esc_html__( 'Body font', 'seosight' ),
				'default' => seosight_get_unyson_option( 'typography_body', array(
					'font-family' => 'Default',
				    'color' => '#7b7b7b'
				), 'customizer', 'typography' ),
				'line_height' => false,
				'text_align' => false,
				'preview' => false
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_typography',
		'title'  => esc_html__( 'H1 headings', 'seosight' ),
		'fields' => array(
			array(
				'id'        => 'typography_h1',
				'type'      => 'typography',
				'title'      => esc_html__( 'H1 headings', 'seosight' ),
				'default' => seosight_get_unyson_option( 'typography_h1', array(
					'font-family' => 'Default',
				    'color' => '#2f2c2c'
				), 'customizer', 'typography' ),
				'line_height' => false,
				'text_align' => false,
				'preview' => false
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_typography',
		'title'  => esc_html__( 'H2 headings', 'seosight' ),
		'fields' => array(
			array(
				'id'        => 'typography_h2',
				'type'      => 'typography',
				'title'      => esc_html__( 'H2 headings', 'seosight' ),
				'default' => seosight_get_unyson_option( 'typography_h2', array(
					'font-family' => 'Default',
				    'color' => '#2f2c2c'
				), 'customizer', 'typography' ),
				'line_height' => false,
				'text_align' => false,
				'preview' => false
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_typography',
		'title'  => esc_html__( 'H3 headings', 'seosight' ),
		'fields' => array(
			array(
				'id'        => 'typography_h3',
				'type'      => 'typography',
				'title'      => esc_html__( 'H3 headings', 'seosight' ),
				'default' => seosight_get_unyson_option( 'typography_h3', array(
					'font-family' => 'Default',
				    'color' => '#2f2c2c'
				), 'customizer', 'typography' ),
				'line_height' => false,
				'text_align' => false,
				'preview' => false
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_typography',
		'title'  => esc_html__( 'H4 headings', 'seosight' ),
		'fields' => array(
			array(
				'id'        => 'typography_h4',
				'type'      => 'typography',
				'title'      => esc_html__( 'H4 headings', 'seosight' ),
				'default' => seosight_get_unyson_option( 'typography_h4', array(
					'font-family' => 'Default',
				    'color' => '#2f2c2c'
				), 'customizer', 'typography' ),
				'line_height' => false,
				'text_align' => false,
				'preview' => false
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_typography',
		'title'  => esc_html__( 'H5 headings', 'seosight' ),
		'fields' => array(
			array(
				'id'        => 'typography_h5',
				'type'      => 'typography',
				'title'      => esc_html__( 'H5 headings', 'seosight' ),
				'default' => seosight_get_unyson_option( 'typography_h5', array(
					'font-family' => 'Default',
				    'color' => '#2f2c2c'
				), 'customizer', 'typography' ),
				'line_height' => false,
				'text_align' => false,
				'preview' => false
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_typography',
		'title'  => esc_html__( 'H6 headings', 'seosight' ),
		'fields' => array(
			array(
				'id'        => 'typography_h6',
				'type'      => 'typography',
				'title'      => esc_html__( 'H6 headings', 'seosight' ),
				'default' => seosight_get_unyson_option( 'typography_h6', array(
					'font-family' => 'Default',
				    'color' => '#2f2c2c'
				), 'customizer', 'typography' ),
				'line_height' => false,
				'text_align' => false,
				'preview' => false
			)
		)
	) );
	// Typography section (END)

	// Header options section
	CSF::createSection( $customize_prefix, array(
		'id' => 'panel_header',
		'title'  => esc_html__( 'Header options', 'seosight' ),
		'priority' => 125,
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_header',
		'title'  => esc_html__('Top bar', 'seosight'),
		'fields' => array(
			array(
				'id'        => 'sections-top-bar',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => array(
					array(
						'id'    => 'status',
						'type'  => 'switcher',
						'title' => esc_html__('Top bar', 'seosight'),
						'text_on' => esc_html__('Show', 'seosight'),
						'text_off' => esc_html__('Hide', 'seosight'),
						'text_width' => 70,
						'default' => ( seosight_get_unyson_option( 'sections-top-bar/status' ) == 'show' ) ? true : false
					),
					array(
						'id' => 'theme-style',
						'type'  => 'select',
						'title' => esc_html__('Theme style', 'seosight'),
						'options' => array(
							'' => esc_html__('White', 'seosight'),
                            'top-bar-dark' => esc_html__('Dark', 'seosight'),
						),
						'default' => seosight_get_unyson_option( 'sections-top-bar/show/theme-style', 'top-bar-dark' ),
						'dependency' => array( 'status', '==', '1' ),
					),
					array(
						'id'    => 'show-languages',
						'type'  => 'switcher',
						'title' => esc_html__('Languages selector', 'seosight'),
						'subtitle' => esc_html__('Works only with translate plugin  ','seosight'),
						'text_on' => esc_html__('Show', 'seosight'),
						'text_off' => esc_html__('Hide', 'seosight'),
						'text_width' => 70,
						'dependency' => array( 'status', '==', '1' ),
						'default' => ( seosight_get_unyson_option( 'sections-top-bar/show/show-languages/status' ) == 'show' ) ? true : false
					),
					array(
						'id' => 'language-select',
						'type'  => 'radio',
						'title' => esc_html__('Use language switcher', 'seosight'),
						'options' => array(
							'theme-select' => esc_html__('WPML or Polylang switcher', 'seosight'),
                            'plugin-select' => esc_html__('Other plugin shortcode', 'seosight'),
						),
						'default' => seosight_get_unyson_option( 'sections-top-bar/show/show-languages/show/language-select/status', 'theme-select' ),
						'dependency' => array( 'status|show-languages', '==|==', '1|1' ),
					),
					array(
						'id' => 'shortcode',
						'type'  => 'text',
						'title' => esc_html__('Provide plugin selector shortcode', 'seosight'),
						'dependency' => array( 'status|show-languages|language-select', '==|==|==', '1|1|plugin-select' ),
						'default' => seosight_get_unyson_option( 'sections-top-bar/show/show-languages/show/language-select/plugin-select/shortcode', '' ),
					),
					array(
						'id'     => 'info-boxes',
						'type'   => 'repeater',
						'title' => esc_html__('Text fields', 'seosight'),
						'subtitle' => esc_html__('Add you phone, email etc.', 'seosight'),
						'fields' => array(
							array(
								'id' => 'info',
								'type'   => 'text',
								'title' => esc_html__('Text','seosight'),
							)
						),
						'default' => seosight_get_unyson_option( 'sections-top-bar/show/info-boxes', array(array('info' => 'info@seosight.com')) ),
						'dependency' => array( 'status', '==', '1' ),
					),
					array(
						'id'     => 'social-networks',
						'type'   => 'repeater',
						'title' => esc_html__( 'Social networks', 'seosight' ),
						'default' => seosight_get_unyson_option( 'sections-top-bar/show/social-networks',
						array(
							array(
								'link' => 'https://www.facebook.com/',
								'icon' => 'facebook.svg',
							),
							array(
								'link' => 'https://www.youtube.com/',
								'icon' => 'youtube.svg',
							),
							array(
								'link' => 'https://twitter.com',
								'icon' => 'twitter.svg',
							),
						) ),
						'fields' => array(
							array(
								'id' => 'link',
								'type'   => 'text',
								'title' => esc_html__( 'Link to social network page', 'seosight' ),
							),
							array(
								'id' => 'icon',
								'type'   => 'select',
								'title' => esc_html__( 'Icon', 'seosight' ),
								'subtitle' => esc_html__( 'Icons of social networks with links to profile', 'seosight' ),
								'default' => 'phone',
								'options' => seosight_social_network_icons()
							),
						),
						'dependency' => array( 'status', '==', '1' ),
					),
					array(
						'id'    => 'show-login',
						'type'  => 'switcher',
						'title' => esc_html__('Login/Logout block', 'seosight'),
						'text_on' => esc_html__('Show', 'seosight'),
						'text_off' => esc_html__('Hide', 'seosight'),
						'text_width' => 70,
						'default' => ( seosight_get_unyson_option( 'sections-top-bar/show/show-login/status' ) == 'show' ) ? true : false,
						'dependency' => array( 'status', '==', '1' ),
					),
				)
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_header',
		'title'   => esc_html__( 'Menu panel', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'sticky_header_desktop',
				'type'  => 'switcher',
				'title' => esc_html__( 'Sticky header on desktop?', 'seosight' ),
				'default' => seosight_get_unyson_option( 'sticky_header_desktop', true )
			),
			array(
				'id'    => 'sticky_header_mobile',
				'type'  => 'switcher',
				'title' => esc_html__( 'Sticky header on mobile?', 'seosight' ),
				'default' => seosight_get_unyson_option( 'sticky_header_mobile', false )
			),
			array(
				'id'    => 'header_bg_color',
				'type'  => 'color',
				'title' => esc_html__( 'Background Color', 'seosight' ),
				'subtitle' => esc_html__( 'If you choose no image to display - that color will be set as background', 'seosight' ),
				'help' => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'header_bg_color', '#ffffff' ),
				'transport' => 'postMessage'
			),
			array(
				'id'    => 'typography_nav',
				'type'  => 'typography',
				'title' => esc_html__( 'Menu typography', 'seosight' ),
				'default' => seosight_get_unyson_option( 'typography_nav', array(
					'font-family' => 'Default',
				    'color' => '#2f2c2c'
				), 'customizer', 'typography' ),
				'font_family' => true,
				'font_size' => true,
				'line_height' => false,
				'text_align' => false,
				'letter_spacing' => true,
				'color' => true,
				'preview' => false
			),
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_header',
		'title'   => esc_html__( 'Logotype', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'logo-image',
				'type'  => 'upload',
				'title' => esc_html__( 'Logotype Image', 'seosight' ),
				'library' => 'image',
				'default' => seosight_get_unyson_option( 'logo-image/url', '' ),
			),
			array(
				'id'    => 'logo-retina',
				'type'  => 'switcher',
				'title' => esc_html__( 'Logo in Retina?', 'seosight' ),
				'subtitle' => esc_html__( 'This image wil be displayed twice smaller than uploaded image size.', 'seosight' ),
				'default' => seosight_get_unyson_option( 'logo-retina', false )
			),
			array(
				'id' => 'logo-title',
				'type'   => 'text',
				'title' => esc_html__( 'Logotype text', 'seosight' ),
				'subtitle' => esc_html__( 'Write your logo title', 'seosight' ),
				'default' => seosight_get_unyson_option( 'logo-title', get_bloginfo( 'name' ) )
			),
			array(
				'id' => 'logo-subtitle',
				'type'   => 'text',
				'title' => esc_html__( 'Logotype description', 'seosight' ),
				'subtitle' => esc_html__( 'Write your logo description', 'seosight' ),
				'default' => seosight_get_unyson_option( 'logo-subtitle', get_bloginfo( 'description' ) )
			),
			array(
				'id'    => 'typography_logo',
				'type'  => 'typography',
				'title' => esc_html__( 'Logo typography', 'seosight' ),
				'default' => seosight_get_unyson_option( 'typography_logo', array(
					'font-family' => 'Default',
				    'color' => '#2f2c2c'
				), 'customizer', 'typography' ),
				'font_family' => true,
				'font_size' => false,
				'line_height' => false,
				'text_align' => false,
				'letter_spacing' => true,
				'color' => true,
				'preview' => false
			),
			array(
				'id' => 'typography_logo_title_fz',
				'type'  => 'number',
				'title' => esc_html__( 'Title font size', 'seosight' ),
				'unit' => 'px'
			),
			array(
				'id' => 'typography_logo_descr_fz',
				'type'  => 'number',
				'title' => esc_html__( 'Description font size', 'seosight' ),
				'unit' => 'px'
			),
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_header',
		'title'   => esc_html__( 'Search', 'seosight' ),
		'fields' => array(
			array(
				'id'        => 'search-icon',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => array(
					array(
						'id'    => 'value',
						'type'  => 'switcher',
						'title' => esc_html__( 'Show search icon?', 'seosight' ),
						'subtitle' => esc_html__( 'Will enable search icon in page header', 'seosight' ),
						'text_on' => esc_html__('Show', 'seosight'),
						'text_off' => esc_html__('Hide', 'seosight'),
						'text_width' => 70,
						'default' => ( seosight_get_unyson_option( 'search-icon/value' ) == 'no' ) ? false : true,
					),
					array(
						'id'    => 'style',
						'type'  => 'image_select',
						'title' => esc_html__( 'Select search style', 'seosight' ),
						'subtitle' => esc_html__( 'Different styles for search that show on icon click', 'seosight' ),
						'options'   => array(
							'fullscreen' => get_template_directory_uri() . '/img/admin/search_full.png',
							'dropdown'   => get_template_directory_uri() . '/img/admin/search_drop.png',
						),
						'default' => seosight_get_unyson_option( 'search-icon/yes/style', 'fullscreen' ),
						'dependency' => array( 'value', '==', '1' ),
					)
				)
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_header',
		'title'   => esc_html__( 'Aside sidebar', 'seosight' ),
		'fields' => array(
			array(
				'id'        => 'aside-panel',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => array(
					array(
						'id'    => 'value',
						'type'  => 'switcher',
						'title' => esc_html__( 'Show aside open button?', 'seosight' ),
						'subtitle' => esc_html__( 'Will enable button and aside panel', 'seosight' ),
						'text_on' => esc_html__('Show', 'seosight'),
						'text_off' => esc_html__('Hide', 'seosight'),
						'text_width' => 70,
						'default' => ( seosight_get_unyson_option( 'aside-panel/value' ) == 'yes' ) ? true : false,
					),
					array(
						'id'    => 'icon',
						'type'  => 'upload',
						'title' => esc_html__( 'Custom icon', 'seosight' ),
						'subtitle' => esc_html__( 'Custom icon for opening menu', 'seosight' ),
						'library' => 'image',
						'dependency' => array( 'value', '==', '1' ),
						'default' => seosight_get_unyson_option( 'aside-panel/yes/icon/url', '' )
					),
					array(
						'id'    => 'logo',
						'type'  => 'switcher',
						'title' => esc_html__( 'Show logo?', 'seosight' ),
						'subtitle' => esc_html__( 'Logotype on aside panel', 'seosight' ),
						'default' => seosight_get_unyson_option( 'aside-panel/yes/logo', true ),
						'dependency' => array( 'value', '==', '1' ),
					),
					array(
						'id'    => 'text',
						'type'  => 'textarea',
						'title' => esc_html__( 'Text Block', 'seosight' ),
						'subtitle' => esc_html__( 'Text block on aside panel', 'seosight' ),
						'default' => seosight_get_unyson_option( 'aside-panel/yes/text', '' ),
						'dependency' => array( 'value', '==', '1' ),
					)
				),
			)
		)
	) );
	// Header options section (END)

	// Footer options section
	CSF::createSection( $customize_prefix, array(
		'id' => 'panel_footer',
		'title'  => esc_html__( 'Footer options', 'seosight' ),
		'priority' => 127,
	) );
	
	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_footer',
		'title'   => esc_html__( 'Design', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'footer_text_color',
				'type'  => 'color',
				'title' => esc_html__( 'Text Color', 'seosight' ),
				'help'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'footer_text_color', '' ),
				'transport' => 'postMessage'
			),
			array(
				'id'    => 'footer_title_color',
				'type'  => 'color',
				'title' => esc_html__( 'Titles and Links  Color', 'seosight' ),
				'help'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'footer_title_color', '' ),
				'transport' => 'postMessage'
			),
			array(
				'id'    => 'footer_bg_image_type',
				'type'  => 'radio',
				'title' => esc_html__( 'Background image', 'seosight' ),
				'subtitle' => esc_html__( 'Select one of images or upload your own pattern', 'seosight' ),
				'options'    => array(
					'predefined' => esc_html__( 'Predefined images', 'seosight' ),
					'custom' => esc_html__( 'Custom image', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'footer_bg_image/type', 'predefined' ),
			),
			array(
				'id'    => 'footer_bg_image_predefined',
				'type'  => 'image_select',
				'title' => false,
				'options' => seosight_backgrounds(),
				'default' => seosight_get_unyson_option( 'footer_bg_image/predefined', 'none' ),
				'dependency' => array( 'footer_bg_image_type', '==', 'predefined' ),
			),
			array(
				'id'    => 'footer_bg_image_custom',
				'type'  => 'upload',
				'library'  => 'image',
				'title' => false,
				'default' => seosight_get_unyson_option( 'footer_bg_image/custom', '', 'customizer', 'background' ),
				'dependency' => array( 'footer_bg_image_type', '==', 'custom' ),
			),
			array(
				'id'    => 'footer_bg_cover',
				'type'  => 'switcher',
				'title' => esc_html__( 'Expand background', 'seosight' ),
				'subtitle' => esc_html__( 'Don\'t repeat image and expand it to full section background', 'seosight' ),
				'default' => seosight_get_unyson_option( 'footer_bg_cover', false ),
				'transport' => 'postMessage'
			),
			array(
				'id'    => 'footer_fixed',
				'type'  => 'switcher',
				'title' => esc_html__( 'Fixed footer effect', 'seosight' ),
				'subtitle' => esc_html__( 'Add sliding effect for your footer.', 'seosight' ),
				'default' => seosight_get_unyson_option( 'footer_fixed', false )
			),
			array(
				'id'    => 'footer_bg_color',
				'type'  => 'color',
				'title' => esc_html__( 'Background Color', 'seosight' ),
				'subtitle'  => esc_html__( 'If you choose no image to display - that color will be set as background', 'seosight' ),
				'help'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'footer_bg_color', '' ),
				'transport' => 'postMessage'
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_footer',
		'title'   => esc_html__( 'Widgets section', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'site-description',
				'type'  => 'fieldset',
				'title' => false,
				'fields' => array(
					array(
						'id'    => 'value',
						'type'  => 'switcher',
						'title' => esc_html__( 'Show text block', 'seosight' ),
						'subtitle' => esc_html__( 'Text block with description in footer', 'seosight' ),
						'text_on' => esc_html__('Show', 'seosight'),
						'text_off' => esc_html__('Hide', 'seosight'),
						'text_width' => 70,
						'default' => ( seosight_get_unyson_option( 'site-description/value' ) == 'yes' ) ? true : false,
					),
					array(
						'id'    => 'width-columns',
						'type'  => 'slider',
						'title' => esc_html__( 'Text block width', 'seosight' ),
						'subtitle' => esc_html__( 'Select width in 12 column grid', 'seosight' ),
						'help'       => esc_html__( 'More about grid and columns you can read here', 'seosight' ) . ' - <a href="http://getbootstrap.com/css/#grid" target="_blank">Bootstrap Grid</a>',
						'default' => seosight_get_unyson_option( 'site-description/yes/width-columns', 7 ),
						'min'     => 2,
						'max'     => 12,
						'step'    => 1,
						'dependency' => array( 'value', '==', '1' ),
					),
					array(
						'id'    => 'description',
						'type'  => 'fieldset',
						'title' => esc_html__( 'Text block Content', 'seosight' ),
						'fields' => array(
							array(
								'id'    => 'title',
								'title' => esc_html__( 'Title', 'seosight' ),
								'type'  => 'text',
								'default' => seosight_get_unyson_option( 'site-description/yes/description/title', '' ),
							),
							array(
								'id'    => 'desc',
								'type'  => 'wp_editor',
								'title' => esc_html__( 'Text in column', 'seosight' ),
								'subtitle' => esc_html__( 'Text in left footer column', 'seosight' ),
								'tinymce'       => true,
								'quicktags'     => true,
								'media_buttons' => true,
								'height'        => '200px',
								'default' => seosight_get_unyson_option( 'site-description/yes/description/desc', '' ),
							),
						),
						'dependency' => array( 'value', '==', '1' ),
					),
					array(
						'id'    => 'social-networks',
						'type'  => 'repeater',
						'title' => esc_html__( 'Social networks', 'seosight' ),
						'default' => seosight_get_unyson_option( 'site-description/yes/social-networks', array() ),
						'fields' => array(
							array(
								'id'    => 'link',
								'title' => esc_html__( 'Link to social network page', 'seosight' ),
								'type'  => 'text',
							),
							array(
								'id'    => 'icon',
								'title' => esc_html__( 'Icon', 'seosight' ),
								'type'  => 'select',
								'default' => 'phone',
								'options' => seosight_social_network_icons()
							),
						),
						'dependency' => array( 'value', '==', '1' ),
					),
					array(
						'id'    => 'class',
						'type'  => 'text',
						'title' => esc_html__( 'Additional class', 'seosight' ),
						'subtitle' => esc_html__( 'Custom CSS class will be added to this block', 'seosight' ),
						'dependency' => array( 'value', '==', '1' ),
						'default' => seosight_get_unyson_option( 'site-description/yes/class', '' )
					)
				)
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_footer',
		'title'   => esc_html__( 'Contacts section', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'footer_contacts_show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show section with contacts', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'footer_contacts_show' ) == 'no' ) ? false : true,
			),
			array(
				'id'    => 'footer_contacts',
				'type'  => 'repeater',
				'title' => esc_html__( 'Boxes with contacts', 'seosight' ),
				'default' => seosight_get_unyson_option( 'footer_contacts', array() ),
				'fields' => array(
					array(
						'id'    => 'title',
						'title' => esc_html__( 'Title', 'seosight' ),
						'type'  => 'text',
					),
					array(
						'id'    => 'subtitle',
						'title' => esc_html__( 'Subtitle', 'seosight' ),
						'type'  => 'text',
					),
					array(
						'id'    => 'icon',
						'title' => esc_html__( 'Icon', 'seosight' ),
						'type'  => 'select',
						'options' => array(
							'phone'   => esc_html__( 'Phone', 'seosight' ),
							'phone2' => esc_html__( 'Phone', 'seosight' ) . ' 2',
							'mail'    => esc_html__( 'Mail', 'seosight' ),
							'address' => esc_html__( 'Address', 'seosight' ),
							'address2' => esc_html__( 'Address', 'seosight' ) . ' 2',
							'address3' => esc_html__( 'Address', 'seosight' ) . ' 3',
							'chat'   => esc_html__( 'Chat', 'seosight' ),
							'service' => esc_html__( 'Service', 'seosight' ),
							'service2' => esc_html__( 'Service', 'seosight' ) . ' 2',
						)
					),
					array(
						'id'    => 'color',
						'type'  => 'color',
						'title' => esc_html__( 'Icon Color', 'seosight' ),
					)
				),
				'max' => 4
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_footer',
		'title'   => esc_html__( 'Copyright field', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'footer_copyright',
				'title' => esc_html__( 'Copyright text', 'seosight' ),
				'type'  => 'textarea',
				'default' => seosight_get_unyson_option( 'footer_copyright', 'Site is built on WordPress <a href="https://wordpress.org">WordPress</a>')
			),
			array(
				'id'    => 'size_copyright_section',
				'type'  => 'radio',
				'title' => esc_html__( 'Section height', 'seosight' ),
				'options' => array(
					'large'  => esc_html__( 'Large', 'seosight' ),
					'medium' => esc_html__( 'Medium', 'seosight' ),
					'small'  => esc_html__( 'Small', 'seosight' ),
				),
				'default'   => seosight_get_unyson_option( 'size_copyright_section', 'large' ),
				'inline'  => true,
			),
			array(
				'id'    => 'copyright_bg_color',
				'type'  => 'color',
				'title' => esc_html__( 'Background Color', 'seosight' ),
				'help'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'copyright_bg_color', '' ),
				'transport' => 'postMessage'
			),
			array(
				'id'    => 'copyright_text_color',
				'type'  => 'color',
				'title' => esc_html__( 'Text Color', 'seosight' ),
				'help'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'copyright_text_color', '' ),
				'transport' => 'postMessage'
			)
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_footer',
		'title'   => esc_html__( 'Scroll Top Button', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'scroll_top_icon',
				'type'  => 'fieldset',
				'title' => false,
				'fields' => array(
					array(
						'id'    => 'value',
						'type'  => 'switcher',
						'title' => esc_html__( 'Show Scroll to top button?', 'seosight' ),
						'subtitle' => esc_html__( 'Display or hide button that scroll page to top on click.', 'seosight' ),
						'text_on' => esc_html__('Show', 'seosight'),
						'text_off' => esc_html__('Hide', 'seosight'),
						'text_width' => 70,
						'default' => ( seosight_get_unyson_option( 'scroll_top_icon/value' ) == 'no' ) ? false : true,
					),
					array(
						'id'    => 'fixed',
						'type'  => 'switcher',
						'title' => esc_html__( 'Become fixed', 'seosight' ),
						'subtitle' => esc_html__( 'Make button fixed. By default will be shown in footer only', 'seosight' ),
						'default' => seosight_get_unyson_option( 'scroll_top_icon/yes/fixed', false ),
						'dependency' => array( 'value', '==', '1' ),
					),
					array(
						'id'    => 'custom_icon',
						'type'  => 'upload',
						'title' => esc_html__('Custom icon', 'seosight'),
						'subtitle' => esc_html__('You can upload own image for To Top button', 'seosight'),
						'library' => 'image',
						'default' => seosight_get_unyson_option( 'scroll_top_icon/yes/custom_icon/url', '' ),
						'dependency' => array( 'value', '==', '1' ),
					),
					array(
						'id'    => 'icon_size',
						'type'  => 'slider',
						'title' => esc_html__( 'Icon width', 'seosight' ),
						'min'     => 10,
						'max'     => 150,
						'step'    => 10,
						'default' => seosight_get_unyson_option( 'scroll_top_icon/yes/icon_size', 40 ),
						'dependency' => array( 'value', '==', '1' ),
					),
					array(
						'id'    => 'bg_color',
						'type'  => 'color',
						'title' => esc_html__( 'Background Color', 'seosight' ),
						'help'  => esc_html__( 'Layer with colored overlay for background image', 'seosight' ),
						'default' => seosight_get_unyson_option( 'scroll_top_icon/yes/bg_color', '' ),
						'dependency' => array( 'value', '==', '1' ),
					)
				)
			)
		)
	) );
	// Footer options section (END)
	
	// Design customize section
	CSF::createSection( $customize_prefix, array(
		'title'  => esc_html__( 'Design customize', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'website_preloader',
				'type'  => 'switcher',
				'default' => seosight_get_unyson_option( 'website_preloader', false ),
				'title' => esc_html__( 'Enable website pre-loader', 'seosight' ),
			),
			array(
				'id'    => 'sidebar_width',
				'type'  => 'select',
				'title' => esc_html__( 'Sidebar width', 'seosight' ),
				'subtitle' => esc_html__( 'Choose between wide and narrow sidebar on your pages', 'seosight' ),
				'options' => array(
					'narrow' => esc_html__( 'Narrow', 'seosight' ),
					'wide'   => esc_html__( 'Wide', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'sidebar_width', 'narrow' )
			),
			array(
				'id'        => 'sections_padding',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => array(
				  array(
					'id'    => 'sections_padding_picker',
					'type'  => 'radio',
					'title' => esc_html__( 'Sections padding', 'seosight' ),
					'options' => array(
						'small'  => esc_html__( 'Small', 'seosight' ),
						'medium' => esc_html__( 'Medium', 'seosight' ),
						'large'  => esc_html__( 'Large', 'seosight' ),
						'custom' => esc_html__( 'Custom', 'seosight' ),
					),
					'inline' => true,
					'default' => seosight_get_unyson_option( 'sections_padding/sections_padding_picker', 'medium' )
				  ),
				  array(
					'id'        => 'custom',
					'type'      => 'fieldset',
					'title'     => false,
					'fields'    => array(
						array(
							'id'    => 'top',
							'type'  => 'number',
							'title' => esc_html__( 'Padding top', 'seosight' ),
							'subtitle' => esc_html__( 'Number only', 'seosight' ),
							'default' => seosight_get_unyson_option( 'sections_padding/custom/top', 100 )
						),
						array(
							'id'    => 'bottom',
							'type'  => 'number',
							'title' => esc_html__( 'Padding bottom', 'seosight' ),
							'subtitle' => esc_html__( 'Number only', 'seosight' ),
							'default' => seosight_get_unyson_option( 'sections_padding/custom/bottom', 100 )
						),
					),
					'dependency' => array( 'sections_padding_picker', '==', 'custom' ),
				  )
				),
			),
		),
		'priority' => 130,
	) );
	// Design customize section (END)

	// Blog options section
	CSF::createSection( $customize_prefix, array(
		'id' => 'panel_blog_options',
		'title'  => esc_html__( 'Blog options', 'seosight' ),
		'priority' => 136,
	) );

	$args = [
		'post_type' => 'page',
		'numberposts'      => 1,
		'fields' => 'ids',
		'nopaging' => true,
		'meta_key' => '_wp_page_template',
		'meta_value' => 'blog-template.php'
	];
	$default_blog_page = get_posts( $args );
	$default_blog_page_v = '';
	if( !empty($default_blog_page) ){
		$default_blog_page_v = (isset($default_blog_page[0]->ID)) ? $default_blog_page[0]->ID : '';
	}

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_blog_options',
		'title'   => esc_html__( 'General options', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'blog-primary-page',
				'type'  => 'select',
				'title' => esc_html__( 'Primary Blog page', 'seosight' ),
				'subtitle' => esc_html__( 'Select a page which breadcrumbs will be linked to', 'seosight' ),
				'help' => esc_html__( 'Click on field and type page name to find page', 'seosight' ),
				'options'     => 'pages',
				// 'chosen' => true,
				// 'ajax' => true,
				'query_args'  => array(
					'posts_per_page' => -1
				),
				'default' => seosight_get_unyson_option( 'blog-primary-page/0', $default_blog_page_v )
			),
			array(
				'id'    => 'blog-date-update',
				'type'  => 'select',
				'title' => esc_html__( 'Date to show', 'seosight' ),
				'subtitle' => esc_html__( 'Select what date display in post meta', 'seosight' ),
				'options' => array(
					'creation' => esc_html__( 'Post creation', 'seosight' ),
					'updated'  => esc_html__( 'Post last update', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'blog-date-update', 'updated' ),
			),
			array(
				'id'    => 'flip-prev-next-order',
				'type'  => 'switcher',
				'title' => esc_html__( 'Prev/Next Order', 'seosight' ),
				'subtitle' => esc_html__( 'Swap posts that displayed in Prev / Next block', 'seosight' ),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'text_width' => 60,
				'default' => ( seosight_get_unyson_option( 'flip-prev-next-order' ) == 'yes' ) ? true : false
			),
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_blog_options',
		'title'   => esc_html__( 'Archive / Category options', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'blog-search-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show Search panel', 'seosight' ),
				'subtitle' => esc_html__( 'Show or hide panel before posts list', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'blog-search-show' ) == 'yes' ) ? true : false
			),
			array(
				'id'    => 'blog-author-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show author?', 'seosight' ),
				'subtitle' => esc_html__( 'Author name and avatar block', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'blog-author-show' ) == 'no' ) ? false : true
			),
			array(
				'id'    => 'blog-meta-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show post meta?', 'seosight' ),
				'subtitle' => esc_html__( 'Post time, categories, tags, comments info', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'blog-meta-show' ) == 'no' ) ? false : true
			),
		)
	) );

	CSF::createSection( $customize_prefix, array(
		'parent' => 'panel_blog_options',
		'title'   => esc_html__( 'Single Post options', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'single-featured-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show featured media?', 'seosight' ),
				'subtitle' => esc_html__( 'Featured image or other media on top of post', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'single-featured-show' ) == 'no' ) ? false : true
			),
			array(
				'id'    => 'single-author-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show author?', 'seosight' ),
				'subtitle' => esc_html__( 'Author name and avatar block', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'single-author-show' ) == 'no' ) ? false : true
			),
			array(
				'id'    => 'single-meta-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show post meta?', 'seosight' ),
				'subtitle' => esc_html__( 'Post time, categories, tags, comments info', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'single-meta-show' ) == 'no' ) ? false : true
			),
			array(
				'id'    => 'single-share-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show share post buttons?', 'seosight' ),
				'subtitle' => esc_html__( 'Show icons that share post on social networks', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'single-share-show' ) == 'no' ) ? false : true
			),
			array(
				'id'    => 'author-box-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show author box?', 'seosight' ),
				'subtitle' => esc_html__( 'Show box with author avatar and detailed bio description', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'author-box-show' ) == 'no' ) ? false : true
			),
			array(
				'id'    => 'single-related-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show related posts?', 'seosight' ),
				'subtitle' => esc_html__( 'Show posts slider with similar posts', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => false
			),
		)
	) );
	// Blog options section (END)

	// Stunning header section
	CSF::createSection( $customize_prefix, array(
		'title'  => esc_html__( 'Stunning header', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'stunning-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Stunning Header Section', 'seosight' ),
				'subtitle' => esc_html__( 'Panel after header will be show/hide from frontend', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'stunning-show/value' ) == 'no' ) ? false : true,
			),
			array(
				'id'        => 'stunning-padding',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => array(
					array(
						'id'    => 'padding-top',
						'type'  => 'number',
						'title' => esc_html__( 'Padding Top', 'seosight' ),
						'subtitle' => esc_html__( 'Number only', 'seosight' ),
						'default' => seosight_get_unyson_option( 'stunning-show/yes/padding-top', '' )
					),
					array(
						'id'    => 'padding-bottom',
						'type'  => 'number',
						'title' => esc_html__( 'Padding Bottom', 'seosight' ),
						'subtitle' => esc_html__( 'Number only', 'seosight' ),
						'default' => seosight_get_unyson_option( 'stunning-show/yes/padding-bottom', '' )
					),
				),
				'dependency' => array( 'stunning-show', '==', '1' ),
			),
			array(
				'id'    => 'stunning_hide_title',
				'type'  => 'switcher',
				'title' => esc_html__( 'Page Title', 'seosight' ),
				'subtitle' => esc_html__( 'You can control visibility of this element', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'stunning_hide_title' ) == 'yes' ) ? false : true,
			),
			array(
				'id'    => 'stunning_hide_breadcrumbs',
				'type'  => 'switcher',
				'title' => esc_html__( 'Breadcrumbs', 'seosight' ),
				'subtitle' => esc_html__( 'You can control visibility of this element', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'stunning_hide_breadcrumbs' ) == 'yes' ) ? false : true,
			),
			array(
				'id'    => 'stunning_bg_color',
				'type'  => 'color',
				'title' => esc_html__( 'Background Color', 'seosight' ),
				'subtitle'  => esc_html__( 'If you choose no image to display - that color will be set as background', 'seosight' ),
				'help'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'stunning_bg_color', '#3e4d50' ),
				'transport' => 'postMessage'
			),
			array(
				'id'    => 'stunning_text_color',
				'type'  => 'color',
				'title' => esc_html__( 'Text Color', 'seosight' ),
				'help'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'stunning_text_color', '' ),
				'transport' => 'postMessage'
			),
			array(
				'id'    => 'stunning_bg_type',
				'type'  => 'image_select',
				'title' => esc_html__( 'Type of background', 'seosight' ),
				'options' => array(
                    'image_bg' => get_template_directory_uri() . '/img/admin/image_bg.png',
                    'video_bg' => get_template_directory_uri() . '/img/admin/video_bg.png',
                ),
				'default' => seosight_get_unyson_option( 'stunning_bg_type/selected', 'image_bg' )
			),
			array(
				'id'    => 'stunning_bg_image',
				'type'  => 'fieldset',
				'title' => false,
				'fields' => array(
					array(
						'id'    => 'stunning_bg_image_type',
						'type'  => 'radio',
						'title' => esc_html__( 'Background image', 'seosight' ),
						'subtitle' => esc_html__( 'Select one of images or upload your own pattern', 'seosight' ),
						'options'    => array(
							'predefined' => esc_html__( 'Predefined images', 'seosight' ),
							'custom' => esc_html__( 'Custom image', 'seosight' ),
						),
						'default' => seosight_get_unyson_option( 'stunning_bg_type/image_bg/stunning_bg_image/type', 'predefined' )
					),
					array(
						'id'    => 'stunning_bg_image_predefined',
						'type'  => 'image_select',
						'title' => false,
						'options' => seosight_backgrounds(),
						'default' => seosight_get_unyson_option( 'stunning_bg_type/image_bg/stunning_bg_image/predefined', 'none' ),
						'dependency' => array( 'stunning_bg_image_type', '==', 'predefined' ),
					),
					array(
						'id'    => 'stunning_bg_image_custom',
						'type'  => 'upload',
						'library'  => 'image',
						'title' => false,
						'default' => seosight_get_unyson_option( 'stunning_bg_type/image_bg/stunning_bg_image/custom', '', 'customizer', 'background' ),
						'dependency' => array( 'stunning_bg_image_type', '==', 'custom' ),
					),
					array(
						'id'    => 'stunning_bg_cover',
						'type'  => 'switcher',
						'title' => esc_html__( 'Expand background', 'seosight' ),
                    	'subtitle'  => esc_html__( 'Don\'t repeat image and expand it to full section background', 'seosight' ),
						'default' => seosight_get_unyson_option( 'stunning_bg_type/image_bg/stunning_bg_cover', false ),
					),
				),
				'dependency' => array( 'stunning_bg_type', '==', 'image_bg' ),
			),
			array(
				'id'    => 'stunning_bg_video',
				'type'  => 'fieldset',
				'title' => false,
				'fields' => array(
					array(
						'id'    => 'placeholder',
						'type'  => 'upload',
						'title' => esc_html__( 'Placeholder Image', 'seosight' ),
						'subtitle' => esc_html__( 'Please select placeholder image', 'seosight' ),
						'library' => 'image',
						'default' => seosight_get_unyson_option( 'stunning_bg_type/video_bg/placeholder/url', '' ),
					),
					array(
						'id'    => 'stunning_bg_cover',
						'type'  => 'radio',
						'title' => esc_html__( 'Video Source', 'seosight' ),
						'options'    => array(
							'oembed' => esc_html__('Youtube', 'seosight'),
							'self' => esc_html__('Self hosted', 'seosight'),
						),
						'inline' => true,
						'default' => seosight_get_unyson_option( 'stunning_bg_type/video_bg/selected/source', 'oembed' ),
					),
					array(
						'id'    => 'stunning_bg_cover_oembed',
						'type'  => 'text',
						'title' => esc_html__( 'Video Link', 'seosight' ),
						'subtitle'  => esc_html__( 'Insert Video URL to embed this video', 'seosight' ),
						'default' => seosight_get_unyson_option( 'stunning_bg_type/video_bg/selected/oembed/source', '' ),
						'dependency' => array( 'stunning_bg_cover', '==', 'oembed' ),
					),
					array(
						'id'    => 'stunning_bg_cover_self_mp4',
						'type'  => 'upload',
						'title' => esc_html__( 'Link to mp4 video', 'seosight' ),
						'subtitle' => esc_html__( 'Source of uploaded video', 'seosight' ),
						'default' => seosight_get_unyson_option( 'stunning_bg_type/video_bg/selected/self/mp4/url', '' ),
						'dependency' => array( 'stunning_bg_cover', '==', 'self' ),
					),
					array(
						'id'    => 'stunning_bg_cover_self_webm',
						'type'  => 'upload',
						'title' => esc_html__( 'Link to webm video', 'seosight' ),
						'subtitle' => esc_html__( 'Source of uploaded video', 'seosight' ),
						'default' => seosight_get_unyson_option( 'stunning_bg_type/video_bg/selected/self/webm/url', '' ),
						'dependency' => array( 'stunning_bg_cover', '==', 'self' ),
					),
					array(
						'id'    => 'stunning_bg_cover_self_ogg',
						'type'  => 'upload',
						'title' => esc_html__( 'Link to ogg video', 'seosight' ),
						'subtitle' => esc_html__( 'Source of uploaded video', 'seosight' ),
						'default' => seosight_get_unyson_option( 'stunning_bg_type/video_bg/selected/self/ogg/url', '' ),
						'dependency' => array( 'stunning_bg_cover', '==', 'self' ),
					),
				),
				'dependency' => array( 'stunning_bg_type', '==', 'video_bg' ),
			),
			array(
				'id'    => 'stunning_overlay',
				'type'  => 'color',
				'title' => esc_html__( 'Color overlay', 'seosight' ),
				'subtitle' => esc_html__( 'Layer with colored overlay for background image', 'seosight' ),
				'default' => seosight_get_unyson_option( 'stunning_overlay', '' ),
			)
		),
		'priority' => 138,
	) );
	// Stunning header section (END)

	// Subscribe panel section
	CSF::createSection( $customize_prefix, array(
		'title'  => esc_html__( 'Subscribe panel', 'seosight' ),
		'fields' => $options->customizer_subscribe(),
		'priority' => 140,
	) );
	// Subscribe panel section (END)
	
	$default_project_page = seosight_get_option_value( 'folio-bottom-nav-page-select', '', array('name' => 'folio-bottom-nav/yes/page_select/0') );

	// Portfolio options section
	$active_extensions = get_option( 'fw_active_extensions' );
	if ( isset( $active_extensions[ 'portfolio' ] ) ) {
	CSF::createSection( $customize_prefix, array(
		'title'  => esc_html__( 'Portfolio options', 'seosight' ),
		'fields' => array(
			array(
				'id'    => 'portfolio-page',
				'type'  => 'select',
				'title' => esc_html__( 'Primary portfolio page', 'seosight' ),
				'subtitle' => esc_html__( 'Select a page which center icon will be linked to', 'seosight' ),
				'help' => esc_html__( 'Click on field and type page name to find page', 'seosight' ),
				'options'     => 'pages',
				// 'chosen' => true,
				// 'ajax' => true,
				'query_args'  => array(
					'posts_per_page' => -1
				),
				'default' => seosight_get_unyson_option( 'portfolio-page/0', $default_project_page ),
			),
			array(
				'id'    => 'thumbnail-align',
				'type'  => 'radio',
				'default'   => seosight_get_unyson_option( 'thumbnail-align', 'left' ),
				'title'   => esc_html__( 'Thumbnail / Slider align', 'seosight' ),
				'subtitle'    => esc_html__( 'Align project media on single page', 'seosight' ),
				'options' => array(
					'left'   => esc_html__( 'Left', 'seosight' ),
					'center' => esc_html__( 'Center', 'seosight' ),
					'right'  => esc_html__( 'Right', 'seosight' ),
				),
				'inline'  => true,
			),
			array(
				'id'    => 'folio-likes-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show Like', 'seosight' ),
				'subtitle' => esc_html__( 'Heart icon with counter who liked page', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'folio-likes-show' ) == 'no' ) ? false : true,
			),
			array(
				'id'    => 'folio-data-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show date?', 'seosight' ),
				'subtitle' => esc_html__( 'Show block with date of created page', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'folio-data-show' ) == 'no' ) ? false : true,
			),
			array(
				'id'    => 'folio-share-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show share icons?', 'seosight' ),
				'subtitle' => esc_html__( 'Icons with script for share post in social networks', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'folio-share-show' ) == 'no' ) ? false : true,
			),
			array(
				'id'    => 'folio-related-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show Related items', 'seosight' ),
				'subtitle' => esc_html__( 'Slider with similar portfolio items category tag', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'folio-related-show/value' ) == 'no' ) ? false : true,
			),
			array(
				'id'    => 'folio-related-show-title',
				'type'  => 'text',
				'title' => esc_html__( 'Related project section title', 'seosight' ),
				'default' => esc_html__( 'More Case Studies', 'seosight' ),
				'dependency' => array( 'folio-related-show', '==', '1' ),
				'default' => seosight_get_unyson_option( 'folio-related-show/yes/block_title', '' )
			),
			array(
				'id'    => 'folio-social-buttons',
				'type'  => 'checkbox',
				'title' => esc_html__( 'Share buttons', 'seosight' ),
				'options' => array(
					'facebook' => esc_html__( 'Facebook', 'seosight' ),
					'twitter' => esc_html__( 'Twitter', 'seosight' ),
					'linkedin' => esc_html__( 'Linkedin', 'seosight' ),
					'pinterest' => esc_html__( 'Pinterest', 'seosight' ),
					'reddit' => esc_html__( 'Reddit', 'seosight' ),
					'tumblr' => esc_html__( 'Tumblr', 'seosight' ),
					'whatsapp' => esc_html__( 'Whatsapp', 'seosight' ),
					'xing' => esc_html__( 'Xing', 'seosight' ),
				),
				'default' => array( 'facebook', 'twitter', 'linkedin', 'pinterest' )
			),
			array(
				'id'    => 'folio-bottom-nav',
				'type'  => 'switcher',
				'title' => esc_html__( 'Enable inner navigation', 'seosight' ),
				'subtitle' => esc_html__( 'Show additional navigation after portfolio', 'seosight' ),
				'text_on' => esc_html__('Enable', 'seosight'),
				'text_off' => esc_html__('Disable', 'seosight'),
				'text_width' => 80,
				'default' => ( seosight_get_unyson_option( 'folio-bottom-nav/post-navigation' ) == 'no' ) ? false : true,
			),
			array(
				'id'    => 'folio-bottom-nav-page-select',
				'type'  => 'select',
				'title' => esc_html__( 'Primary portfolio page', 'seosight' ),
				'subtitle' => esc_html__( 'Select a page which center icon will be linked to', 'seosight' ),
				'help' => esc_html__( 'Click on field and type page name to find page', 'seosight' ),
				'options'     => 'pages',
				// 'chosen' => true,
				// 'ajax' => true,
				'query_args'  => array(
					'posts_per_page' => -1
				),
				'default' => seosight_get_unyson_option( 'folio-bottom-nav/yes/page_select/0', '' ),
				'dependency' => array( 'folio-bottom-nav', '==', '1' ),
			),
		),
		'priority' => 145,
	) );
	}
	// Portfolio options section (END)

	// Additional JS section
	CSF::createSection( $customize_prefix, array(
		'title'  => esc_html__( 'Additional JS', 'seosight' ),
		'fields' => array(
			array(
				'id'       => 'custom-js',
				'type'     => 'code_editor',
				'title'    => esc_html__( 'JS code field', 'seosight' ),
				'subtitle' => wp_kses( __( 'without &lt;script&gt; tags', 'seosight' ), array('&lt;' => array(),'&gt;' => array()) ),
				'settings' => array(
				  'mode'   => 'javascript',
				),
				'default'  => seosight_get_unyson_option( 'custom-js', '' ),
			),
		),
		'priority' => 150,
	) );
	// Additional JS section (END)
}