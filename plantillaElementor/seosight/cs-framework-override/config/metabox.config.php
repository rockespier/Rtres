<?php if ( ! defined( 'ABSPATH' ) ) {
	die;
} // Cannot access pages directly.
// ===============================================================================================
// -----------------------------------------------------------------------------------------------
// METABOX OPTIONS
// -----------------------------------------------------------------------------------------------
// ===============================================================================================


// Control core classes for avoid errors
if( class_exists( 'CSF' ) ) {

	require_once plugin_dir_path( __FILE__ ) .'config-fields-class.php';
	$options = new SeosightThemeOptionsFields();

	$current_post_id = ( isset($_GET['post']) ) ? intval($_GET['post']) : 0;
	$current_term_id = 0;
	$current_term = ( isset($_GET['taxonomy']) ) ? intval($_GET['taxonomy']) : '';
	if( $current_term == 'fw-portfolio-category' || $current_term == 'category' ){
		$current_term_id = ( isset($_GET['tag_ID']) ) ? intval($_GET['tag_ID']) : 0;
	}

	// Page
	$prefix = 'seosight_design_options';
	CSF::createMetabox( $prefix, array(
		'title'     => esc_html__( 'Customize design', 'seosight' ),
		'post_type' => array('page','post','download', 'portfolio-kit' ),
	) );

	CSF::createSection( $prefix, array(
    	'title'  => esc_html__( 'Header', 'seosight' ),
    	'fields' => array(
			array(
				'id' => 'aside-panel',
				'type'  => 'select',
				'title' => esc_html__( 'Show aside open button?', 'seosight' ),
				'subtitle' => esc_html__( 'Will enable button and aside panel', 'seosight' ),
				'options' => array(
					'default' => esc_html__( 'Default', 'seosight' ),
					'yes'     => esc_html__( 'Show', 'seosight' ),
					'no'      => esc_html__( 'Hide', 'seosight' )
				),
				'default' => seosight_get_unyson_option( 'aside-panel', 'default', 'meta/' . $current_post_id ),
			),
			array(
				'id'    => 'custom-header-enable',
				'type'  => 'switcher',
				'title' => esc_html__( 'Change settings?', 'seosight' ),
				'subtitle' => esc_html__( 'Extra settings for element. Will affect only on current page.', 'seosight' ),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'text_width' => 60,
				'default' => ( seosight_get_unyson_option( 'custom-header/enable', 'no', 'meta/' . $current_post_id ) == 'yes' ) ? true : false,
			),
			array(
				'id'        => 'custom-header',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => $options->metabox_header( $current_post_id ),
				'dependency' => array( 'custom-header-enable', '==', '1' ),
			)
		)
	) );

	CSF::createSection( $prefix, array(
    	'title'  => esc_html__( 'Stunning Header', 'seosight' ),
    	'fields' => array(
			array(
				'id'    => 'custom-stunning-enable',
				'type'  => 'switcher',
				'title' => esc_html__( 'Change settings?', 'seosight' ),
				'subtitle' => esc_html__( 'Extra settings for element. Will affect only on current page.', 'seosight' ),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'text_width' => 60,
				'default' => ( seosight_get_unyson_option( 'custom-stunning/enable', 'no', 'meta/' . $current_post_id ) == 'yes' ) ? true : false,
			),
			array(
				'id'    => 'stunning-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show stunning header?', 'seosight' ),
				'subtitle' => esc_html__( 'Panel after header will be shown/hidden from frontend', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/value', 'yes', 'meta/' . $current_post_id ) == 'no' ) ? false : true,
				'dependency' => array( 'custom-stunning-enable', '==', '1' ),
			),
			array(
				'id'        => 'custom-stunning',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => $options->metabox_stunning( $current_post_id ),
				'dependency' => array( 'custom-stunning-enable|stunning-show', '==|==', '1|1' ),
			)
		)
	) );

	CSF::createSection( $prefix, array(
    	'title'  => esc_html__( 'Subscribe panel', 'seosight' ),
    	'fields' => array(
			array(
				'id'    => 'custom-subscribe-enable',
				'type'  => 'switcher',
				'title' => esc_html__( 'Change settings?', 'seosight' ),
				'subtitle' => esc_html__( 'Extra settings for element. Will affect only on current page.', 'seosight' ),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'text_width' => 60,
				'default' => ( seosight_get_unyson_option( 'custom-subscribe/enable', 'no', 'meta/' . $current_post_id ) == 'yes' ) ? true : false,
			),
			array(
				'id'    => 'subscribe-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show Subscribe panel?', 'seosight' ),
				'subtitle' =>  esc_html__( 'Panel before footer will be show/hide from frontend', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'custom-subscribe/yes/subscribe-show/value', 'yes', 'meta/' . $current_post_id ) == 'no' ) ? false : true,
				'dependency' => array( 'custom-subscribe-enable', '==', '1' ),
			),
			array(
				'id'        => 'custom-subscribe',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => $options->metabox_subscribe( $current_post_id ),
				'dependency' => array( 'custom-subscribe-enable|subscribe-show', '==|==', '1|1' ),
			),
		)
	) );

	// Portfolio Page
	$prefix_portfolio = 'seosight_portfolio_page_options';
	CSF::createMetabox( $prefix_portfolio, array(
		'title'     => esc_html__( 'Portfolio page options', 'seosight' ),
		'post_type' => 'page',
		'page_templates' => array(
            'portfolio-template.php',
		),
	) );

	CSF::createSection( $prefix_portfolio, array(
    	'title'  => false,
    	'fields' => array(
			array(
				'id'    => 'sorting_panel',
				'type'  => 'switcher',
				'title' => esc_html__( 'Sort panel', 'seosight' ),
				'subtitle' =>  esc_html__( 'Panel before items with taxonomy categories', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'sorting_panel/value', 'yes', 'meta/' . $current_post_id ) == 'no' ) ? false : true,
			),
			array(
				'id'        => 'sorting_panel_action',
				'type'      => 'select',
				'title'   =>  esc_html__( 'Action on panel link click', 'seosight' ),
				'options' => array(
					'sort'    => esc_html__( 'Sort items on click', 'seosight' ),
					'load'     => esc_html__( 'Open Category archive', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'sorting_panel/yes/action', '', 'meta/' . $current_post_id ),
				'dependency' => array( 'sorting_panel', '==', '1' ),
			),
			array(
				'id'        => 'pagination_type',
				'type'      => 'select',
				'title'   => esc_html__( 'Type of pages pagination', 'seosight' ),
				'subtitle'    => esc_html__( 'Select one of pagination types', 'seosight' ),
				'options' => array(
					'numbers'     => esc_html__( 'Numbers links', 'seosight' ),
					'loadmore'    => esc_html__( 'Load more ajax', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'pagination_type', '', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'order',
				'type'      => 'select',
				'title'   => esc_html__( 'Order', 'seosight' ),
				'subtitle'    => esc_html__( 'Designates the ascending or descending order of items', 'seosight' ),
				'options' => array(
					'default' => esc_html__( 'Default', 'seosight' ),
					'DESC'    => esc_html__( 'Descending', 'seosight' ),
					'ASC'     => esc_html__( 'Ascending', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'order', 'default', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'orderby',
				'type'      => 'select',
				'title'   => esc_html__( 'Order posts by', 'seosight' ),
				'subtitle'    => esc_html__( 'Sort retrieved posts by parameter.', 'seosight' ),
				'options' => array(
					'default'       => esc_html__( 'Default', 'seosight' ),
					'date'          => esc_html__( 'Order by date', 'seosight' ),
					'comment_count' => esc_html__( 'Order by number of comments', 'seosight' ),
					'author'        => esc_html__( 'Order by author.', 'seosight' ),
					'modified'      => esc_html__( 'Order by last modified date.', 'seosight' ),
					'rand'          => esc_html__( 'Random order', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'order_by', 'default', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'taxonomy_select',
				'type'      => 'select',
				'title'      => esc_html__( 'Categories', 'seosight' ),
				'help'       => esc_html__( 'Click on field and type category name to find  category', 'seosight' ),
				'options'     => 'categories',
				'query_args'  => array(
					'taxonomy'  => 'fw-portfolio-category',
				),
				'multiple' => true,
				'default' => seosight_get_unyson_option( 'taxonomy_select', array(), 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'exclude',
				'type'      => 'checkbox',
				'default' => ( seosight_get_unyson_option( 'exclude', '', 'meta/' . $current_post_id ) == '1' ) ? true : false,
				'title' => esc_html__( 'Exclude selected', 'seosight' ),
				'subtitle'  => esc_html__( 'Show all categories except that selected in "Categories" option', 'seosight' ),
				'label'   => esc_html__( 'Exclude', 'seosight' ),
			),
			array(
				'id'        => 'per_page',
				'type'      => 'text',
				'title' => esc_html__( 'Items per page', 'seosight' ),
				'subtitle'  => esc_html__( 'How many portfolios show per page', 'seosight' ),
				'help'  => esc_html__( 'Please input number here. Leave empty for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'per_page', '', 'meta/' . $current_post_id ),
			)
		)
	) );

	// Blog Page
	$prefix_blog = 'seosight_blog_page_options';
	CSF::createMetabox( $prefix_blog, array(
		'title'     => esc_html__( 'Blog page options', 'seosight' ),
		'post_type' => 'page',
		'page_templates' => array(
            'blog-template.php',
			'blog-template-grid.php',
			'blog-template-masonry.php'
		),
	) );

	CSF::createSection( $prefix_blog, array(
    	'title'  => false,
    	'fields' => array(
			array(
				'id'        => 'pagination_type',
				'type'      => 'select',
				'title'   => esc_html__( 'Type of pages pagination', 'seosight' ),
				'subtitle' => esc_html__( 'Select one of pagination types', 'seosight' ),
				'options' => array(
					'numbers'     => esc_html__( 'Numbers links', 'seosight' ),
					'loadmore'    => esc_html__( 'Load more ajax', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'pagination_type', '', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'order',
				'type'      => 'select',
				'title'   => esc_html__( 'Order', 'seosight' ),
				'subtitle' => esc_html__( 'Designates the ascending or descending order of items', 'seosight' ),
				'options' => array(
					'default' => esc_html__( 'Default', 'seosight' ),
					'DESC'    => esc_html__( 'Descending', 'seosight' ),
					'ASC'     => esc_html__( 'Ascending', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'order', '', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'orderby',
				'type'      => 'select',
				'title'   => esc_html__( 'Order posts by', 'seosight' ),
				'subtitle'    => esc_html__( 'Sort retrieved posts by parameter.', 'seosight' ),
				'options' => array(
					'default'       => esc_html__( 'Default', 'seosight' ),
					'date'          => esc_html__( 'Order by date', 'seosight' ),
					'comment_count' => esc_html__( 'Order by number of comments', 'seosight' ),
					'author'        => esc_html__( 'Order by author.', 'seosight' ),
					'modified'      => esc_html__( 'Order by last modified date.', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'orderby', '', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'taxonomy_select',
				'type'      => 'select',
				'title'      => esc_html__( 'Categories', 'seosight' ),
				'help'       => esc_html__( 'Click on field and type category name to find  category', 'seosight' ),
				'options'     => 'categories',
				'multiple' => true,
				'default' => seosight_get_unyson_option( 'taxonomy_select', '', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'exclude',
				'type'      => 'checkbox',
				'default' => ( seosight_get_unyson_option( 'exclude', '', 'meta/' . $current_post_id ) == '1' ) ? true : false,
				'title' => esc_html__( 'Exclude selected', 'seosight' ),
				'subtitle'  => esc_html__( 'Show all categories except that selected in "Categories" option', 'seosight' ),
				'label'   => esc_html__( 'Exclude', 'seosight' ),
			),
			array(
				'id'        => 'per_page',
				'type'      => 'text',
				'title' => esc_html__( 'Items per page', 'seosight' ),
				'subtitle'  => esc_html__( 'How many portfolios show per page', 'seosight' ),
				'help'  => esc_html__( 'Please input number here. Leave empty for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'per_page', '', 'meta/' . $current_post_id ),
			)
		)
	) );

	// Post
	$prefix_post_quote = 'seosight_post_quote';
	CSF::createMetabox( $prefix_post_quote, array(
		'title'     => esc_html__( 'Quote post options', 'seosight' ),
		'post_type' => 'post',
		'post_formats' => 'quote',
	) );

	CSF::createSection( $prefix_post_quote, array(
    	'title'  => false,
    	'fields' => array(
			array(
				'id'        => 'quote_author',
				'type'      => 'text',
				'title' => esc_html__( 'Quote author', 'seosight' ),
				'default' => seosight_get_unyson_option( 'quote_author', '', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'quote_dopinfo',
				'type'      => 'text',
				'title' => esc_html__( 'Author profession', 'seosight' ),
				'default' => seosight_get_unyson_option( 'quote_dopinfo', '', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'quote_avatar',
				'type'      => 'upload',
				'library'  => 'image',
				'title' => esc_html__( 'Author avatar', 'seosight' ),
				'default' => seosight_get_unyson_option( 'quote_avatar/url', '', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'text_color',
				'type'      => 'color',
				'title' => esc_html__( 'Text Color', 'seosight' ),
				'subtitle'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
				'default' => seosight_get_unyson_option( 'text_color', '', 'meta/' . $current_post_id ),
			),
		)
	) );

	$prefix_post_image = 'seosight_post_image';
	CSF::createMetabox( $prefix_post_image, array(
		'title'     => esc_html__( 'Image post options', 'seosight' ),
		'post_type' => 'post',
		'post_formats' => 'image',
	) );

	CSF::createSection( $prefix_post_image, array(
    	'title'  => false,
    	'fields' => array(
			array(
				'id'        => 'enable_overlay',
				'type'      => 'checkbox',
				'default' => true,
				'title' => esc_html__( 'Enable Image Overlay', 'seosight' ),
				'subtitle'  => esc_html__( 'Darken semi-transparent overlay over image', 'seosight' ),
				'text'  => esc_html__( 'Yes', 'seosight' ),
			),
		)
	) );

	$prefix_post_video = 'seosight_post_video';
	CSF::createMetabox( $prefix_post_video, array(
		'title'     => esc_html__( 'Video post options', 'seosight' ),
		'post_type' => 'post',
		'post_formats' => 'video',
	) );

	CSF::createSection( $prefix_post_video, array(
    	'title'  => false,
    	'fields' => array(
			array(
				'id'        => 'oembed',
				'type'      => 'text',
				'title'   => esc_html__( 'Link to video', 'seosight' ),
				'subtitle'    => esc_html__( 'Enter link for video that will be embedded', 'seosight' ),
				'help'    => esc_html__( 'More information about WordPress embeds:', 'seosight' ) . '<br> <a href="https://codex.wordpress.org/Embeds">https://codex.wordpress.org/Embeds</a>',
				'default' => seosight_get_unyson_option( 'video_oembed', '', 'meta/' . $current_post_id ),
			)
		)
	) );

	$prefix_post_audio = 'seosight_post_audio';
	CSF::createMetabox( $prefix_post_audio, array(
		'title'     => esc_html__( 'Audio post options', 'seosight' ),
		'post_type' => 'post',
		'post_formats' => 'audio',
	) );

	CSF::createSection( $prefix_post_audio, array(
    	'title'  => false,
    	'fields' => array(
			array(
				'id'        => 'oembed',
				'type'      => 'text',
				'title'   => esc_html__( 'Link to audio', 'seosight' ),
				'default' => seosight_get_unyson_option( 'audio_oembed', '', 'meta/' . $current_post_id ),
				'subtitle'    => esc_html__( 'Enter link for video that will be embedded', 'seosight' ),
				'help'    => esc_html__( 'More information about WordPress embeds:', 'seosight' ) . '<br> <a href="https://codex.wordpress.org/Embeds">https://codex.wordpress.org/Embeds</a>',
			)
		)
	) );

	$prefix_post_gallery = 'seosight_post_gallery';
	CSF::createMetabox( $prefix_post_gallery, array(
		'title'     => esc_html__( 'Gallery post options', 'seosight' ),
		'post_type' => 'post',
		'post_formats' => 'gallery',
	) );

	CSF::createSection( $prefix_post_gallery, array(
    	'title'  => false,
    	'fields' => array(
			array(
				'id'        => 'gallery_images',
				'type'      => 'gallery',
				'title'    => esc_html__( 'Images in slider on post list:', 'seosight' ),
				'subtitle'  => esc_html__( 'Images that will be displayed in slider on post list pages', 'seosight' ),
				'default' => seosight_get_unyson_option( 'gallery_images', '', 'meta/' . $current_post_id, 'gallery' ),
			)
		)
	) );

	// Post portfolio
	$prefix_fw_portfolio = 'seosight_fw_portfolio';
	CSF::createMetabox( $prefix_fw_portfolio, array(
		'title'     =>  esc_html__( 'Project summary', 'seosight' ),
		'post_type' => 'fw-portfolio',
	) );

	CSF::createSection( $prefix_fw_portfolio, array(
    	'title'  => false,
    	'fields' => array(
			array(
				'id' => 'project-title',
				'type'	 => 'text',
				'title'	 => esc_html__( 'Title', 'seosight' ),
				'subtitle'	 => esc_html__( 'Alternative title for project', 'seosight' ),
				'default' => seosight_get_unyson_option( 'project-title', '', 'meta/' . $current_post_id ),
			),
			array(
				'id' => 'project-desc',
				'type' => 'wp_editor',
				'default' => seosight_get_unyson_option( 'project-desc', '', 'meta/' . $current_post_id ),
			),
			array(
				'id'        => 'project-button',
				'type'      => 'fieldset',
				'title'     => esc_html__( 'Project link', 'seosight' ),
				'fields'    => array(
					array(
						'id' => 'label',
						'type'	 => 'text',
						'title' => esc_html__( 'Button Label', 'seosight' ),
						'subtitle' => esc_html__( 'This is the text that appears on your button', 'seosight' ),
						'default' => seosight_get_unyson_option( 'project-button/label', esc_html__( 'Project link', 'seosight' ), 'meta/' . $current_post_id ),
					),
					array(
						'id' => 'background',
						'type'	 => 'color',
						'title'	 => esc_html__( 'Button Background', 'seosight' ),
						'subtitle'	 => esc_html__( 'This is button background', 'seosight' ),
						'default' => seosight_get_unyson_option( 'project-button/background', '#2f2c2c', 'meta/' . $current_post_id ),
					),
					$options->link($current_post_id)
				)
			)
		)
	) );

	$seosight_fw_portfolio_page_open = 'seosight_fw_portfolio_page_open';
	CSF::createMetabox( $seosight_fw_portfolio_page_open, array(
		'title'     =>  esc_html__( 'Behavior on Portfolio page', 'seosight' ),
		'post_type' => 'fw-portfolio',
		'context'   => 'side',
	) );

	CSF::createSection( $seosight_fw_portfolio_page_open, array(
    	'title'  => false,
    	'fields' => array(
			array(
				'id' => 'open-item',
				'type'	 => 'radio',
				'title'		 => false,
				'options'	 => array(
					'default'	 => esc_html__( 'Open inner project page', 'seosight' ),
					'lightbox'	 => esc_html__( 'Open featured image in lightbox', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'open-item', 'default', 'meta/' . $current_post_id ),
			),
		)
	) );

	$seosight_fw_portfolio_cover_video_box = 'seosight_fw_portfolio_cover_video_box';
	CSF::createMetabox( $seosight_fw_portfolio_cover_video_box, array(
		'title'     =>  esc_html__( 'Cover video', 'seosight' ),
		'post_type' => array( 'fw-portfolio', 'portfolio-kit' ),
	) );

	CSF::createSection( $seosight_fw_portfolio_cover_video_box, array(
    	'title'  => false,
    	'fields' => array(
			array(
				'id' => 'cover-video-type',
				'type'	 => 'radio',
				'title'		 => false,
				'inline'	 => true,
				'options'	 => array(
					'none'	 => esc_html__( 'None', 'seosight' ),
					'link'	 => esc_html__( 'Link', 'seosight' ),
					'source' => esc_html__( 'Source', 'seosight' ),
				),
				'default' => seosight_get_unyson_option( 'cover-video-type', 'none', 'meta/' . $current_post_id ),
			),
			array(
				'id' => 'cover-video-source-url',
				'type' => 'text',
				'title'	 => esc_html__( 'Link', 'seosight' ),
				'default' => seosight_get_unyson_option( 'cover-video-source/link/url', '', 'meta/' . $current_post_id ),
				'dependency' => array( 'cover-video-type', '==', 'link' ),
			),
			array(
				'id' => 'cover-video-source-source',
				'type' => 'upload',
				'label' => esc_html__( 'Source', 'seosight' ),
				'desc' => esc_html__( 'MP4 Only', 'seosight' ),
				'library' => 'video',
				'default' => seosight_get_unyson_option( 'cover-video-source/source/video_source/url', '', 'meta/' . $current_post_id ),
				'dependency' => array( 'cover-video-type', '==', 'source' ),
			),
		)
	) );

	$seosight_fw_portfolio_design_customize = 'seosight_fw_portfolio_design_customize';
	CSF::createMetabox( $seosight_fw_portfolio_design_customize, array(
		'title'     =>  esc_html__( 'Customize design', 'seosight' ),
		'post_type' => 'fw-portfolio',
	) );

	CSF::createSection( $seosight_fw_portfolio_design_customize, array(
    	'title'  => esc_html__( 'Thumbnail', 'seosight' ),
    	'fields' => array(
			array(
				'id'    => 'width-columns',
				'type'  => 'slider',
				'title'		 => esc_html__( 'Item size on Category page', 'seosight' ),
				'subtitle'	=> esc_html__( 'Select width in 12 column grid', 'seosight' ),
				'help'		 => esc_html__( 'More about grid and columns you can read here', 'seosight' ) . ' - <a href="http://getbootstrap.com/css/#grid" target="_blank">Bootstrap Grid</a>',
				'default' => seosight_get_unyson_option( 'width-columns', 4, 'meta/' . $current_post_id ),
				'min'     => 3,
				'max'     => 12,
				'step'    => 1,
			),
			array(
				'id'    => 'thumbnail-align',
				'type'  => 'radio',
				'default' => seosight_get_unyson_option( 'thumbnail-align', 'default', 'meta/' . $current_post_id ),
				'title' => esc_html__( 'Thumbnail / Slider align', 'seosight' ),
				'subtitle' => esc_html__( 'Align project media on single page', 'seosight' ),
				'options' => array(
					'default'	 => esc_html__( 'Default', 'seosight' ),
					'left'		 => esc_html__( 'Left', 'seosight' ),
					'center'	 => esc_html__( 'Center', 'seosight' ),
					'right'		 => esc_html__( 'Right', 'seosight' ),
				),
				'inline'	 => true,
			)
		)
	) );

	CSF::createSection( $seosight_fw_portfolio_design_customize, array(
    	'title'  => esc_html__( 'Project content', 'seosight' ),
    	'fields' => array(
			array(
				'id'    => 'custom-description-enable',
				'type'  => 'switcher',
				'title' => esc_html__( 'Change settings?', 'seosight' ),
				'subtitle' => esc_html__( 'Extra settings for element. Will affect only on current page.', 'seosight' ),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'default' => ( seosight_get_unyson_option( 'custom-description/enable', '', 'meta/' . $current_post_id ) == 'yes' ) ? true : false,
			),
			array(
				'id'    => 'folio-likes-show',
				'type'  => 'select',
				'title'		 => esc_html__( 'Show Like', 'seosight' ),
				'subtitle' => esc_html__( 'Heart icon with counter who liked page', 'seosight' ),
				'default' => seosight_get_unyson_option( 'custom-description/yes/folio-likes-show', 'default', 'meta/' . $current_post_id ),
				'options' => array(
					'default'	 => esc_html__( 'Default', 'seosight' ),
					'yes'		 => esc_html__( 'Show', 'seosight' ),
					'no'		 => esc_html__( 'Hide', 'seosight' ),
				),
				'dependency' => array( 'custom-description-enable', '==', '1' ),
			),
			array(
				'id'    => 'folio-data-show',
				'type'  => 'select',
				'title'		 => esc_html__( 'Show date?', 'seosight' ),
				'subtitle' => esc_html__( 'Show block with date of created page', 'seosight' ),
				'default' => seosight_get_unyson_option( 'custom-description/yes/folio-data-show', 'default', 'meta/' . $current_post_id ),
				'options' => array(
					'default'	 => esc_html__( 'Default', 'seosight' ),
					'yes'		 => esc_html__( 'Show', 'seosight' ),
					'no'		 => esc_html__( 'Hide', 'seosight' ),
				),
				'dependency' => array( 'custom-description-enable', '==', '1' ),
			),
			array(
				'id'    => 'folio-share-show',
				'type'  => 'select',
				'title'	=> esc_html__( 'Show share icons?', 'seosight' ),
				'subtitle' => esc_html__( 'Icons with script for share post in social networks', 'seosight' ),
				'default' => seosight_get_unyson_option( 'custom-description/yes/folio-share-show', 'default', 'meta/' . $current_post_id ),
				'options' => array(
					'default'	 => esc_html__( 'Default', 'seosight' ),
					'yes'		 => esc_html__( 'Show', 'seosight' ),
					'no'		 => esc_html__( 'Hide', 'seosight' ),
				),
				'dependency' => array( 'custom-description-enable', '==', '1' ),
			),
			array(
				'id'    => 'folio-navigation-show',
				'type'  => 'select',
				'title'		 => esc_html__( 'Show posts navigation', 'seosight' ),
				'subtitle' => esc_html__( 'Buttons with previous / next post links', 'seosight' ),
				'default' => seosight_get_unyson_option( 'custom-description/yes/folio-navigation-show', 'default', 'meta/' . $current_post_id ),
				'options' => array(
					'default'	 => esc_html__( 'Default', 'seosight' ),
					'yes'		 => esc_html__( 'Show', 'seosight' ),
					'no'		 => esc_html__( 'Hide', 'seosight' ),
				),
				'dependency' => array( 'custom-description-enable', '==', '1' ),
			),
			array(
				'id'    => 'folio-related-show',
				'type'  => 'select',
				'title'		 => esc_html__( 'Show Related items', 'seosight' ),
				'subtitle'	=> esc_html__( 'Slider with similar portfolio items category tag', 'seosight' ),
				'default' => seosight_get_unyson_option( 'custom-description/yes/folio-related-show', 'default', 'meta/' . $current_post_id ),
				'options' => array(
					'default'	 => esc_html__( 'Default', 'seosight' ),
					'yes'		 => esc_html__( 'Show', 'seosight' ),
					'no'		 => esc_html__( 'Hide', 'seosight' ),
				),
				'dependency' => array( 'custom-description-enable', '==', '1' ),
			),
		)
	) );

	CSF::createSection( $seosight_fw_portfolio_design_customize, array(
    	'title'  => esc_html__( 'Header', 'seosight' ),
    	'fields' => array(
			array(
				'id'    => 'custom-header-enable',
				'type'  => 'switcher',
				'title' => esc_html__( 'Change settings?', 'seosight' ),
				'subtitle' => esc_html__( 'Extra settings for element. Will affect only on current page.', 'seosight' ),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'text_width' => 60,
				'default' => ( seosight_get_unyson_option( 'custom-header/enable', 'no', 'meta/' . $current_post_id ) == 'yes' ) ? true : false,
			),
			array(
				'id'        => 'custom-header',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => $options->metabox_header($current_post_id),
				'dependency' => array( 'custom-header-enable', '==', '1' ),
			)
		)
	) );

	CSF::createSection( $seosight_fw_portfolio_design_customize, array(
    	'title'  => esc_html__( 'Stunning Header', 'seosight' ),
    	'fields' => array(
			array(
				'id'    => 'custom-stunning-enable',
				'type'  => 'switcher',
				'title' => esc_html__( 'Change settings?', 'seosight' ),
				'subtitle' => esc_html__( 'Extra settings for element. Will affect only on current page.', 'seosight' ),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'text_width' => 60,
				'default' => ( seosight_get_unyson_option( 'custom-stunning/enable', 'no', 'meta/' . $current_post_id ) == 'yes' ) ? true : false,
			),
			array(
				'id'    => 'stunning-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show stunning header?', 'seosight' ),
				'subtitle' => esc_html__( 'Panel after header will be shown/hidden from frontend', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/value', 'yes', 'meta/' . $current_post_id ) == 'no' ) ? false : true,
				'dependency' => array( 'custom-stunning-enable', '==', '1' ),
			),
			array(
				'id'        => 'custom-stunning',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => $options->metabox_stunning($current_post_id),
				'dependency' => array( 'custom-stunning-enable|stunning-show', '==|==', '1|1' ),
			)
		)
	) );
			
	// Category
	$prefix_category = 'seosight_category';

	CSF::createTaxonomyOptions( $prefix_category, array(
		'taxonomy'  => array('category', 'fw-portfolio-category'),
		'data_type' => 'serialize', // The type of the database save options. `serialize` or `unserialize`
	) );

	CSF::createSection( $prefix_category, array(
    	'title'  => esc_html__( 'Stunning Header', 'seosight' ),
    	'fields' => array(
			array(
				'id'    => 'custom-stunning-enable',
				'type'  => 'switcher',
				'title' => esc_html__( 'Change settings?', 'seosight' ),
				'subtitle' => esc_html__( 'Extra settings for element. Will affect only on current page.', 'seosight' ),
				'text_on' => esc_html__('Yes', 'seosight'),
				'text_off' => esc_html__('No', 'seosight'),
				'text_width' => 60,
				'default' => ( seosight_get_unyson_option( 'custom-stunning/enable', 'no', 'termmeta/' . $current_term_id ) == 'yes' ) ? true : false,
			),
			array(
				'id'    => 'stunning-show',
				'type'  => 'switcher',
				'title' => esc_html__( 'Show stunning header?', 'seosight' ),
				'subtitle' => esc_html__( 'Panel after header will be shown/hidden from frontend', 'seosight' ),
				'text_on' => esc_html__('Show', 'seosight'),
				'text_off' => esc_html__('Hide', 'seosight'),
				'text_width' => 70,
				'default' => ( seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/value', 'yes', 'termmeta/' . $current_term_id ) == 'no' ) ? false : true,
				'dependency' => array( 'custom-stunning-enable', '==', '1' ),
			),
			array(
				'id'        => 'custom-stunning',
				'type'      => 'fieldset',
				'title'     => false,
				'fields'    => $options->metabox_stunning($current_term_id, 'termmeta'),
				'dependency' => array( 'custom-stunning-enable|stunning-show', '==|==', '1|1' ),
			)
		)
	) );
}