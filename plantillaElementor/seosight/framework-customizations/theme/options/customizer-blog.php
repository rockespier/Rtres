<?php if ( ! defined( 'FW' ) ) {
	die( 'Forbidden' );
}

$args = [
	'post_type' => 'page',
	'numberposts'      => 1,
	'fields' => 'ids',
	'nopaging' => true,
	'meta_key' => '_wp_page_template',
	'meta_value' => 'blog-template.php'
];
$default_blog_page = get_posts( $args );

$options = array(
	'section_general'   => array(
		'title'   => esc_html__( 'General options', 'seosight' ),
		'options' => array(
			'blog-primary-page' => array(
				'type'       => 'multi-select',
				'label'      => esc_html__( 'Primary Blog page', 'seosight' ),
				'desc'       => esc_html__( 'Select a page which breadcrumbs will be linked to', 'seosight' ),
				'help'       => esc_html__( 'Click on field and type page name to find page', 'seosight' ),
				'population' => 'posts',
				'source'     => 'page',
				'limit'      => 1,
				'value'      => $default_blog_page
			),
			'blog-date-update' => array(
				'type'       => 'select',
				'label'      => esc_html__( 'Date to show', 'seosight' ),
				'desc'       => esc_html__( 'Select what date display in post meta', 'seosight' ),
				'choices' => array(
					'creation'     => esc_html__( 'Post creation', 'seosight' ),
					'updated'    => esc_html__( 'Post last update', 'seosight' ),
				),
				'value'      => 'updated',

			),
			'flip-prev-next-order' => array(
				'label'        => esc_html__( 'Prev/Next Order', 'seosight' ),
				'desc'         => esc_html__( 'Swap posts that displayed in Prev / Next block', 'seosight' ),
				'type'         => 'switch',
				'right-choice'  => array(
					'value' => 'yes',
					'label' => esc_html__( 'Yes', 'seosight' )
				),
				'left-choice' => array(
					'value' => 'no',
					'label' => esc_html__( 'No', 'seosight' )
				),
				'value'        => 'no',
			),
		)
	),
	'section_archive'   => array(
		'title'   => esc_html__( 'Archive / Category options', 'seosight' ),
		'options' => array(
			'blog-search-show' => array(
				'label'        => esc_html__( 'Show Search panel', 'seosight' ),
				'desc'         => esc_html__( 'Show or hide panel before posts list', 'seosight' ),
				'type'         => 'switch',
				'right-choice'  => array(
					'value' => 'yes',
					'label' => esc_html__( 'Show', 'seosight' )
				),
				'left-choice' => array(
					'value' => 'no',
					'label' => esc_html__( 'Hide', 'seosight' )
				),
				'value'        => 'no',
			),
			'blog-author-show' => array(
				'label'        => esc_html__( 'Show author?', 'seosight' ),
				'desc'         => esc_html__( 'Author name and avatar block', 'seosight' ),
				'type'         => 'switch',
				'right-choice'  => array(
					'value' => 'yes',
					'label' => esc_html__( 'Show', 'seosight' )
				),
				'left-choice' => array(
					'value' => 'no',
					'label' => esc_html__( 'Hide', 'seosight' )
				),
				'value'        => 'yes',
			),
			'blog-meta-show' => array(
				'label'        => esc_html__( 'Show post meta?', 'seosight' ),
				'desc'         => esc_html__( 'Post time, categories, tags, comments info', 'seosight' ),
				'type'         => 'switch',
				'right-choice'  => array(
					'value' => 'yes',
					'label' => esc_html__( 'Show', 'seosight' )
				),
				'left-choice' => array(
					'value' => 'no',
					'label' => esc_html__( 'Hide', 'seosight' )
				),
				'value'        => 'yes',
			),
		)
	),
	'section_post'   => array(
		'title'   => esc_html__( 'Single Post options', 'seosight' ),
		'options' => array(

			'single-featured-show' => array(
				'label'        => esc_html__( 'Show featured media?', 'seosight' ),
				'desc'         => esc_html__( 'Featured image or other media on top of post', 'seosight' ),
				'type'         => 'switch',
				'left-choice'  => array(
					'value' => 'yes',
					'label' => esc_html__( 'Show', 'seosight' )
				),
				'right-choice' => array(
					'value' => 'no',
					'label' => esc_html__( 'Hide', 'seosight' )
				),
				'value'        => 'yes',
			),
			'single-author-show' => array(
				'label'        => esc_html__( 'Show author?', 'seosight' ),
				'desc'         => esc_html__( 'Author name and avatar block', 'seosight' ),
				'type'         => 'switch',
				'left-choice'  => array(
					'value' => 'yes',
					'label' => esc_html__( 'Show', 'seosight' )
				),
				'right-choice' => array(
					'value' => 'no',
					'label' => esc_html__( 'Hide', 'seosight' )
				),
				'value'        => 'yes',
			),
			'single-meta-show' => array(
				'label'        => esc_html__( 'Show post meta?', 'seosight' ),
				'desc'         => esc_html__( 'Post time, categories, tags, comments info', 'seosight' ),
				'type'         => 'switch',
				'left-choice'  => array(
					'value' => 'yes',
					'label' => esc_html__( 'Show', 'seosight' )
				),
				'right-choice' => array(
					'value' => 'no',
					'label' => esc_html__( 'Hide', 'seosight' )
				),
				'value'        => 'yes',
			),
			'single-share-show' => array(
				'label'        => esc_html__( 'Show share post buttons?', 'seosight' ),
				'desc'         => esc_html__( 'Show icons that share post on social networks', 'seosight' ),
				'type'         => 'switch',
				'left-choice'  => array(
					'value' => 'yes',
					'label' => esc_html__( 'Show', 'seosight' )
				),
				'right-choice' => array(
					'value' => 'no',
					'label' => esc_html__( 'Hide', 'seosight' )
				),
				'value'        => 'yes',
			),
			'author-box-show' => array(
				'label'        => esc_html__( 'Show author box?', 'seosight' ),
				'desc'         => esc_html__( 'Show box with author avatar and detailed bio description', 'seosight' ),
				'type'         => 'switch',
				'left-choice'  => array(
					'value' => 'yes',
					'label' => esc_html__( 'Show', 'seosight' )
				),
				'right-choice' => array(
					'value' => 'no',
					'label' => esc_html__( 'Hide', 'seosight' )
				),
				'value'        => 'yes',
			),
		),
	)
);


