<?php

if ( ! defined( 'ABSPATH' ) ) {
	die( 'Direct access forbidden.' );
}
/**
 * Filters and Actions
 */

/**
 * Enqueue Google fonts style to admin screen for custom header display.
 * @internal
 */
function _action_seosight_admin_fonts() {
	wp_enqueue_style( 'seosight-font', seosight_font_url(), array(), '1.0' );
}

add_action( 'admin_print_scripts-appearance_page_custom-header', '_action_seosight_admin_fonts' );

if ( ! function_exists( '_action_seosight_setup' ) ) :
	/**
	 * Theme setup.
	 *
	 * Set up theme defaults and registers support for various WordPress features.
	 *
	 * Note that this function is hooked into the after_setup_theme hook, which
	 * runs before the init hook. The init hook is too late for some features, such
	 * as indicating support post thumbnails.
	 * @internal
	 */
	{

		function _action_seosight_setup() {
			// Add custom background
			add_theme_support( 'custom-background', array(
				'wp-head-callback' => 'seosight_custom_background_cb',
			) );

			add_theme_support( "title-tag" );
			/*
			 * Make Theme available for translation.
			 */
			load_theme_textdomain( 'seosight', get_template_directory() . '/languages/theme' );

			// Add RSS feed links to <head> for posts and comments.
			add_theme_support( 'automatic-feed-links' );

			// Enable support for Post Thumbnails, and declare two sizes.
			add_theme_support( 'post-thumbnails' );
			set_post_thumbnail_size( 690, 420, true );
			add_image_size( 'seosight-full-width', 1038, 576, true );
			add_image_size( 'seosight-full', 1170, 576, true );

			/*
			 * Switch default core markup for search form, comment form, and comments
			 * to output valid HTML5.
			 */
			add_theme_support( 'html5', array(
				'search-form',
				'comment-form',
				'comment-list',
				'gallery',
				'caption'
			) );

			/*
			 * Enable support for Post Formats.
			 * See http://codex.wordpress.org/Post_Formats
			 */
			add_theme_support( 'post-formats', array(
				'video',
				'audio',
				'quote',
				'link',
				'gallery',
			) );

			// This theme uses its own gallery styles.
			add_filter( 'use_default_gallery_style', '__return_false' );

			// Declare 3-rd party plugins support
			add_theme_support( 'woocommerce', array(
				'product_grid' => array(
					'default_rows'    => 4,
					'min_rows'        => 2,
					'max_rows'        => 9,
					'default_columns' => 3,
					'min_columns'     => 2,
					'max_columns'     => 5,
				),
			) );
			add_theme_support( 'wc-product-gallery-zoom' );
			add_theme_support( 'wc-product-gallery-lightbox' );
			add_theme_support( 'wc-product-gallery-slider' );

			// Change kingcomposer modules path
			global $kc;
			if ( $kc && is_child_theme() && class_exists( 'KingComposer' ) ) {
				$kc->set_template_path( get_stylesheet_directory() . KDS . 'kingcomposer' . KDS );
			}

		}

	}
endif;
add_action( 'after_setup_theme', '_action_seosight_setup' );

/**
 * Extend the default WordPress body classes.
 *
 * Adds body classes to denote:
 * 1. Single or multiple authors.
 * 2. Presence of header image.
 * 3. Index views.
 * 4. Full-width content layout.
 * 5. Presence of footer widgets.
 * 6. Single views.
 *
 * @param array $classes A list of existing body class values.
 *
 * @return array The filtered body class list.
 * @internal
 */
function _filter_seosight_body_classes( $classes ) {
	if ( is_multi_author() ) {
		$classes[] = 'group-blog';
	}

	if ( is_archive() || is_search() || is_home() ) {
		$classes[] = 'list-view';
	}

	if ( is_active_sidebar( 'sidebar-footer' ) ) {
		$classes[] = 'footer-widgets';
	}

	if ( is_singular() && ! is_front_page() ) {
		$classes[] = 'singular';
	}

	$classes[] = 'crumina-grid';

	return $classes;
}

add_filter( 'body_class', '_filter_seosight_body_classes' );

/**
 * Extend the default WordPress post classes.
 *
 * Adds a post class to denote:
 * Non-password protected page with a post thumbnail.
 *
 * @param array $classes A list of existing post class values.
 *
 * @return array The filtered post class list.
 * @internal
 */
function _filter_seosight_post_classes( $classes ) {
	if ( ! post_password_required() && ! is_attachment() && has_post_thumbnail() ) {
		$classes[] = 'has-post-thumbnail';
	}

	return $classes;
}

add_filter( 'post_class', '_filter_seosight_post_classes' );

/**
 * Create a nicely formatted and more specific title element text for output
 * in head of document, based on current view.
 *
 * @param string $title Default title text for current view.
 * @param string $sep Optional separator.
 *
 * @return string The filtered title.
 * @internal
 */
function _filter_seosight_wp_title( $title, $sep ) {
	global $paged, $page;

	if ( is_feed() ) {
		return $title;
	}

	// Add the site name.
	$title .= get_bloginfo( 'name', 'display' );

	// Add the site description for the home/front page.
	$site_description = get_bloginfo( 'description', 'display' );
	if ( $site_description && ( is_home() || is_front_page() ) ) {
		$title = "$title $sep $site_description";
	}

	// Add a page number if necessary.
	if ( $paged >= 2 || $page >= 2 ) {
		$title = "$title $sep " . sprintf( esc_html__( 'Page %s', 'seosight' ), max( $paged, $page ) );
	}

	return $title;
}

add_filter( 'wp_title', '_filter_seosight_wp_title', 10, 2 );

/**
 * Flush out the transients used in seosight_categorized_blog.
 * @internal
 */
function _action_seosight_category_transient_flusher() {
	// Like, beat it. Dig?
	delete_transient( 'seosight_category_count' );
}

add_action( 'edit_category', '_action_seosight_category_transient_flusher' );
add_action( 'save_post', '_action_seosight_category_transient_flusher' );

/**
 * Register widget areas.
 * @internal
 */
function _action_seosight_widgets_init() {

	register_sidebar( array(
		'name'          => esc_html__( 'Main Widget Area', 'seosight' ),
		'id'            => 'sidebar-main',
		'description'   => esc_html__( 'Appears in the right section of the site.', 'seosight' ),
		'before_widget' => '<aside id="%1$s" class="widget %2$s">',
		'after_widget'  => '</aside>',
		'before_title'  => '<div class="crumina-heading widget-heading"><h5 class="heading-title">',
		'after_title'   => '</h5><div class="heading-decoration"><span class="first"></span><span class="second"></span></div></div>',
	) );
	register_sidebar( array(
		'name'          => esc_html__( 'Hidden Widget Area', 'seosight' ),
		'id'            => 'sidebar-hidden',
		'description'   => esc_html__( 'Appears in the Hidden section. If available.', 'seosight' ),
		'before_widget' => '<aside id="%1$s" class="widget %2$s">',
		'after_widget'  => '</aside>',
		'before_title'  => '<h4 class="heading-title">',
		'after_title'   => '</h4>',
	) );
	register_sidebar( array(
		'name'          => esc_html__( 'Footer Widget Area', 'seosight' ),
		'id'            => 'sidebar-footer',
		'description'   => esc_html__( 'Appears in footer section. Every widget in own column ', 'seosight' ),
		'before_widget' => '<aside id="%1$s" class="widget %2$s columns_class_replace">',
		'after_widget'  => '</aside>',
		'before_title'  => '<div class="crumina-heading widget-heading"><h4 class="heading-title">',
		'after_title'   => '</h4><div class="heading-decoration"><span class="first"></span><span class="second"></span></div></div>',
	) );
}

add_action( 'widgets_init', '_action_seosight_widgets_init' );

/**
 * Count Widgets
 * Count the number of widgets to add dynamic column class
 *
 * @param string $sidebar_id id of sidebar
 *
 * @since 1.0.0
 *
 * @return int
 */
function seosight_get_widget_columns( $sidebar_id ) {
	// Default number of columns in grid is 12
	$columns = apply_filters( 'seosight_columns', 12 );

	// get the sidebar widgets
	$the_sidebars = wp_get_sidebars_widgets();

	// if sidebar doesn't exist return error
	if ( ! isset( $the_sidebars[ $sidebar_id ] ) ) {
		return esc_html__( 'Invalid sidebar ID', 'seosight' );
	}

	/* count number of widgets in the sidebar
	  and do some simple math to calculate the columns */
	$num = count( $the_sidebars[ $sidebar_id ] );

	switch ( $num ) {
		case 1 :
			$num = $columns;
			break;
		case 2 :
			$num = $columns / 2;
			break;
		case 3 :
			$num = $columns / 3;
			break;
		case 4 :
			$num = $columns / 4;
			break;
		case 5 :
			$num = $columns / 5;
			break;
		case 6 :
			$num = $columns / 6;
			break;
		case 7 :
			$num = $columns / 7;
			break;
		case 8 :
			$num = $columns / 8;
			break;
	}
	$num = floor( $num );

	return $num;
}

if ( defined( 'FW' ) ):
	/**
	 * Display current submitted FW_Form errors
	 * @return array
	 */
	if ( ! function_exists( '_action_seosight_display_form_errors' ) ):

		function _action_seosight_display_form_errors() {
			$form = FW_Form::get_submitted();

			if ( ! $form || $form->is_valid() ) {
				return;
			}

			wp_enqueue_script(
				'seosight-show-form-errors',
				get_template_directory_uri() . '/js/form-errors.js',
				array( 'jquery' ),
				'1.0',
				true
			);

			wp_localize_script( 'seosight-show-form-errors', '_localized_form_errors', array(
				'errors'  => $form->get_errors(),
				'form_id' => $form->get_id()
			) );
		}

	endif;
	add_action( 'wp_enqueue_scripts', '_action_seosight_display_form_errors' );
endif;

/**
 * Custom read more Link formatting
 *
 * @return string
 */
function seosight_read_more_link() {
	return '<div class="more-link"><a href="' . get_permalink() . '" class="btn btn-small btn--dark btn-hover-shadow"><span class="text">' . esc_html__( 'Continue Reading', 'seosight' ) . '</span><i class="seoicon-right-arrow"></i></a></div>';
}

function seosight_excerpt_link( $output ) {
	return $output . '</p><div class="more-link"><a href="' . get_permalink() . '" class="btn btn-small btn--dark btn-hover-shadow"><span class="text">' . esc_html__( 'Continue Reading', 'seosight' ) . '</span><i class="seoicon-right-arrow"></i></a></div>';
}

add_filter( 'the_content_more_link', 'seosight_read_more_link' );
add_filter( 'the_excerpt', 'seosight_excerpt_link' );

function seosight_move_comment_field_to_bottom( $fields ) {
	$comment_field = $fields['comment'];
	unset( $fields['comment'] );
	$fields['comment'] = $comment_field;

	return $fields;
}

add_filter( 'comment_form_fields', 'seosight_move_comment_field_to_bottom' );

add_filter(
	'fw:option_type:icon-v2:packs',
	'_add_more_packs'
);

function _add_more_packs( $default_packs ) {
	return array(
		'seosight' => array(
			'name'             => 'seosight',
			'css_class_prefix' => 'seoicon',
			'css_file'         => get_template_directory() . '/css/crumina-icons.css',
			'css_file_uri'     => get_template_directory_uri() . '/css/crumina-icons.css'
		)
	);
}

function _filter_seosight_disable_sliders( $sliders ) {
	foreach ( array( 'owl-carousel', 'bx-slider', 'nivo-slider' ) as $name ) {
		$key = array_search( $name, $sliders );
		unset( $sliders[ $key ] );
	}

	return $sliders;
}

add_filter( 'fw_ext_slider_activated', '_filter_seosight_disable_sliders' );

/**
 * Add tags to allowedtags filter
 */
function seosight_extend_allowed_tags() {
	global $allowedtags;

	$allowedtags['i']    = array(
		'class' => array(),
	);
	$allowedtags['br']   = array(
		'class' => array(),
	);
	$allowedtags['img']  = array(
		'src'    => array(),
		'alt'    => array(),
		'width'  => array(),
		'height' => array(),
		'class'  => array(),
	);
	$allowedtags['span'] = array(
		'class' => array(),
		'style' => array(),
	);
	$allowedtags['a']    = array(
		'class'   => array(),
		'href'    => array(),
		'target'  => array(),
		'onclick' => array(),
		'rel'     => array(),
	);
}

add_action( 'init', 'seosight_extend_allowed_tags' );

/**
 * Change text strings
 *
 * @link http://codex.wordpress.org/Plugin_API/Filter_Reference/gettext
 */
function seosight_text_strings( $translated_text, $text, $domain ) {
	switch ( $translated_text ) {
		case 'Add Sidebar' :
			$translated_text = esc_html__( 'Save changes', 'seosight' );
			break;
	}

	return $translated_text;
}

add_filter( 'gettext', 'seosight_text_strings', 20, 3 );

/**
 * Disable content editor for page template.
 */
function seosight_disable_admin_metabox() {

	$only = array(
		'only' => array( array( 'id' => 'page' ) ),
	);
	if ( function_exists( 'fw_current_screen_match' ) && fw_current_screen_match( $only ) ) {
		$post_id = ( isset( $_GET['post'] ) ) ? $_GET['post'] : '';
		if ( empty( $post_id ) ) {
			remove_meta_box( 'fw-options-box-portfolio-page', 'page', 'normal' );
			remove_meta_box( 'fw-options-box-blog-page', 'page', 'normal' );
		}
		$template_file = get_post_meta( $post_id, '_wp_page_template', true );
		if ( 'portfolio-template.php' === $template_file ) {
			remove_meta_box( 'fw-options-box-blog-page', 'page', 'normal' );
		} elseif ( 'blog-template.php' === $template_file || 'blog-template-grid.php' === $template_file || 'blog-template-masonry.php' === $template_file ) {
			remove_meta_box( 'fw-options-box-portfolio-page', 'page', 'normal' );
		} else {
			remove_meta_box( 'fw-options-box-portfolio-page', 'page', 'normal' );
			remove_meta_box( 'fw-options-box-blog-page', 'page', 'normal' );
		}
	}
}

add_action( 'do_meta_boxes', 'seosight_disable_admin_metabox', 99 );

/**
 * Extend the default WordPress category title.
 *
 * Remove 'Category' word from cat title.
 *
 * @param string $title Original category title.
 *
 * @return string The filtered category title.
 * @internal
 */
function _filter_seosight_archive_title( $title ) {
	if ( is_home() ) {
		$title = esc_html__( 'Latest posts', 'seosight' );
	} elseif ( is_category() ) {
		$title = single_cat_title( '', false );
	} elseif ( ( is_singular( 'post' ) ) ) {
		$category = get_the_category( get_the_ID() );
		$title    = $category[0]->name;
	} elseif ( is_singular( 'product' ) || is_singular( 'download' ) ) {
		$title = '<h2 class="stunning-header-title h1">' . esc_html__( 'Product Details', 'seosight' ) . '</h2>';
	}

	return $title;
}

add_filter( 'get_the_archive_title', '_filter_seosight_archive_title' );

/**
 *  Demo install config
 *
 * @param FW_Ext_Backups_Demo[] $demos
 *
 * @return FW_Ext_Backups_Demo[]
 */
function _filter_seosight_fw_ext_backups_demos( $demos ) {
	$demos_array = array(
		'seosight-elementor'    => array(
			'title'        => esc_html__( 'Elementor Demo', 'seosight' ),
			'screenshot'   => get_template_directory_uri() . '/images/seosight-with-elementor.png',
			'preview_link' => 'https://seosight.crumina.net/',
		),
		/*'seosight-kingcomposer' => array(
			'title'        => esc_html__( 'KingComposer Demo', 'seosight' ),
			'screenshot'   => get_template_directory_uri() . '/images/seosight-with-kingcomposer.png',
			'preview_link' => 'https://seosight.crumina.net/',
		),*/
	);

	$download_url = 'http://up.crumina.net/demo-data/seosight/upload.php';

	foreach ( $demos_array as $id => $data ) {
		$demo = new FW_Ext_Backups_Demo( $id, 'piecemeal', array(
			'url'     => $download_url,
			'file_id' => $id,
		) );
		$demo->set_title( $data['title'] );
		$demo->set_screenshot( $data['screenshot'] );
		$demo->set_preview_link( $data['preview_link'] );

		$demos[ $demo->get_id() ] = $demo;

		unset( $demo );
	}

	return $demos;
}

add_filter( 'fw:ext:backups-demo:demos', '_filter_seosight_fw_ext_backups_demos' );

function _filter_seosight_fw_db_keep_options( $keep, $is_full_backup ) {

	$keep = $keep + array(
			'crum_seosight_auto_install_state' => true,
			'SeosightSEO_lic_Key' => true,
            'seosight_update_new_license' => true,
		);

	return $keep;
}

add_filter( 'fw_ext_backups_db_restore_keep_options', '_filter_seosight_fw_db_keep_options', 10, 2 );

/**
 * Modify query to remove a post type from search results, but keep all others
 *
 * @author Joshua David Nelson, josh@joshuadnelson.com
 * @license http://www.gnu.org/licenses/gpl-2.0.html GPLv2+
 */
add_action( 'pre_get_posts', 'seosight_search_modify_query' );

function seosight_search_modify_query( $query ) {

	// First, make sure this isn't the admin and is the main query, otherwise bail
	if ( is_admin() || ! $query->is_main_query() ) {
		return;
	}

	// If this is a search result query
	if ( $query->is_search() ) {
		// Gather all searchable post types
		$in_search_post_types = get_post_types( array( 'exclude_from_search' => false ) );
		// The post type you're removing, in this example 'kc-section'
		$post_type_to_remove = 'kc-section';
		// Make sure you got the proper results, and that your post type is in the results
		if ( is_array( $in_search_post_types ) && in_array( $post_type_to_remove, $in_search_post_types ) ) {
			// Remove the post type from the array
			unset( $in_search_post_types[ $post_type_to_remove ] );
			// set the query to the remaining searchable post types
			$query->set( 'post_type', $in_search_post_types );
		}
	}
}

/**
 * Extension update message
 */
add_action( 'admin_notices', 'seosight_update_checker_message' );

function seosight_update_checker_message() {

	if ( ! function_exists( 'fw' ) ) {
		return;
	}

	$update_checker = fw()->extensions->get( 'update-checker' );
	if ( ! $update_checker ) {
		return;
	}

	if ( ! version_compare( $update_checker->manifest->get_version(), '2.0.0', '<' ) ) {
		return;
	}

	$class   = 'notice notice-error';
	$message = __( sprintf( 'Please, delete and reinstall Unyson Update checker to get automatic theme updates. <a href="%1$s" class="button button-primary" target="_blank">%2$s</a>', 'https://support.crumina.net/help-center/articles/252/theme-is-not-activated', esc_html__( 'View instruction', 'seosight' ) ), 'seosight' );

	printf( '<div class="%1$s"><p>%2$s</p></div>', esc_attr( $class ), $message );
}

/**
 * Add shortcode support for text widgets
 */
add_filter( 'widget_text', 'shortcode_unautop' );
add_filter( 'widget_text', 'do_shortcode' );

/**
 * Enqueue woocommerce scripts
 */
add_filter( 'woocommerce_is_checkout', 'seosight_woocommerce_is_checkout' );

function seosight_woocommerce_is_checkout( $checkout ) {
	global $post;

	if ( ! isset( $post->post_content_filtered ) ) {
		return $checkout;
	}

	if ( has_shortcode( $post->post_content_filtered, 'woocommerce_checkout' ) ) {
		$checkout = true;
	}

	return $checkout;
}

add_action( 'fw_extensions_before_init', '_action_crum_disable_fw_blog' );

function _action_crum_disable_fw_blog() {
	if ( ( $e = get_option( 'fw_active_extensions' ) ) && isset( $e['update-checker'] ) ) {
		unset( $e['update-checker'] );
		update_option( 'fw_active_extensions', $e );
	}
}

// Notice to install KingComposer Seosight.
add_action( 'admin_init', 'seosight_check_kingcomposer_seosight' );
function seosight_check_kingcomposer_seosight() {
	if ( ! class_exists( 'KingComposer_Seosight' ) && in_array( 'kingcomposer/kingcomposer.php', apply_filters( 'active_plugins', get_option( 'active_plugins' ) ) ) ) {
		add_action( 'admin_notices', 'seosight_check_kingcomposer_seosight_notice' );
	}
}

function seosight_check_kingcomposer_seosight_notice() {
	$dismissed = get_option( 'seosight_kc_notice_dismissed', '' );
	if ( $dismissed != '1' ) {
		$tgm_link     = '';
		$action       = 'install';
		$notice_class = ' notice-error';

		$pathpluginurl = WP_PLUGIN_DIR . '/kingcomposer-seosight/kingcomposer-seosight.php';
		$isinstalled   = file_exists( $pathpluginurl );
		if ( $isinstalled ) {
			$action       = 'activate';
			$notice_class = '';
		}

		if ( class_exists( 'TGM_Plugin_Activation' ) ) {
			$tgm      = new TGM_Plugin_Activation();
			$tgm_link = $tgm->get_tgmpa_status_url( $action );
		}
		?>
        <div class="notice seosight-kc-notice<?php echo esc_attr( $notice_class ); ?> is-dismissible">
			<?php
			echo wp_sprintf( __( 'We moved all theme widgets to a separate plugin. Please, %s the %s plugin to reactivate them.', 'seosight' ), $action, '<a href="' . esc_url( $tgm_link ) . '"><b>KingComposer Seosight</b></a>' );
			?>
        </div>
		<?php
	}
}

add_action( 'wp_ajax_seosight_dismissed_notice', 'seosight_dismissed_notice_save' );
function seosight_dismissed_notice_save() {
	update_option( 'seosight_kc_notice_dismissed', '1' );
	exit;
}

// Redirect to TGM page after theme update
add_action( 'upgrader_process_complete', 'seosight_theme_upgrate_check', 10, 2 );
function seosight_theme_upgrate_check( $upgrader_object, $hook_extra ) {
	$themes_arr = ( isset( $hook_extra['themes'] ) ) ? $hook_extra['themes'] : array();
	if ( in_array( 'seosight', $themes_arr ) ) {
		set_transient( 'seosight_upe_updated', 1 );
	}
}

add_action( 'admin_init', 'seosight_theme_upgrate_redirect' );
function seosight_theme_upgrate_redirect() {
	if ( get_transient( 'seosight_upe_updated' ) ) {
		if ( is_admin() && ! defined( 'DOING_AJAX' ) && class_exists( 'TGMPA_List_Table' ) ) {
			$tgmpa_list_table = new TGMPA_List_Table();
			$plugins          = $tgmpa_list_table->categorize_plugins_to_views();
			$plugins_all      = ( isset( $plugins['all'] ) ) ? $plugins['all'] : array();
			$do_redirect      = false;
			if ( ! empty( $plugins_all ) ) {
				foreach ( $plugins_all as $pl ) {
					if ( isset( $pl['required'] ) && $pl['required'] == '1' ) {
						$do_redirect = true;
					}
				}
			}
			if ( true === $do_redirect ) {
				$tgm_link = '';
				if ( class_exists( 'TGM_Plugin_Activation' ) ) {
					$tgm      = new TGM_Plugin_Activation();
					$tgm_link = $tgm->get_tgmpa_status_url( 'install' );
				}
				if ( $tgm_link != '' ) {
					delete_transient( 'seosight_upe_updated' );
					wp_redirect( $tgm_link );
					exit;
				}
			}
		}
	}
	delete_transient( 'seosight_upe_updated' );
}

add_filter( 'wp_nav_menu_objects', 'seosight_filter_fw_ext_mega_menu_wp_nav_menu_objects', 20, 2 );
function seosight_filter_fw_ext_mega_menu_wp_nav_menu_objects( $sorted_menu_items, $args ) {
	$mega_menu = array();
	foreach ( $sorted_menu_items as $item ) {
		$mega_fields      = get_post_meta( $item->ID, 'seosight_menu_options', true );
		$enable_mega_menu = ( isset( $mega_fields['megamenu-enable'] ) ) ? $mega_fields['megamenu-enable'] : false;
		if ( $item->menu_item_parent == 0 && $enable_mega_menu ) {
			if ( defined( 'FW' ) && fw_ext( 'megamenu' ) ) {
				$mega_menu[ $item->ID ] = true;
			}
		}
	}

	foreach ( $sorted_menu_items as $item ) {
		if ( isset( $mega_menu[ $item->ID ] ) ) {
			$item->classes[] = 'menu-item-has-mega-menu';
		}
		if ( isset( $mega_menu[ $item->menu_item_parent ] ) ) {
			$item->classes[] = 'mega-menu-col';
		}
		$parsed_icn = get_post_meta( $item->ID, 'seosight_menu_icon', true );
		$icon_class = isset( $parsed_icn['icon_class'] ) ? $parsed_icn['icon_class'] : '';
		$icon_url   = isset( $parsed_icn['icon_url'] ) ? $parsed_icn['icon_url'] : '';
		if ( $icon_class != '' || $icon_url != '' ) {
			$item->classes[] = 'menu-item-has-icon';
		}
	}

	return $sorted_menu_items;
}

/**
 * Update new options
 */
add_action( 'admin_init', 'seosight_update_new_options' );
function seosight_update_new_options() {
	$meta_update = get_option( 'seosight_new_options_update' );
	if ( $meta_update != '1' ) {
		seosight_regenerate_menu_meta();
		seosight_regenerate_subscribe_customizer_options();
		seosight_update_email_subscribers_option();
		update_option( 'seosight_new_options_update', '1' );
	}

	$customizer_meta_update = get_option( 'seosight_new_options_customizer_update' );
	if ( $customizer_meta_update != '2' ) {
		seosight_update_customizer_options();
		update_option( 'seosight_new_options_customizer_update', '2' );
	}
}

/**
 * Regenerate menu meta.
 */
function seosight_regenerate_menu_meta() {
	$query = new WP_Query( array(
		'post_type'      => 'nav_menu_item',
		'posts_per_page' => - 1
	) );

	$menu_items      = $query->get_posts();
	$menu_items_meta = array();

	if ( ! empty( $menu_items ) ) {
		foreach ( $menu_items as $menu_item ) {
			$single_meta          = array();
			$single_meta_icon_arr = array();
			$item_id              = $menu_item->ID;
			$mega_menu_meta       = get_post_meta( $item_id, 'mega-menu', true );
			if ( ! empty( $mega_menu_meta ) ) {
				$single_meta_icon                   = ( isset( $mega_menu_meta['icon'] ) ) ? $mega_menu_meta['icon'] : '';
				$single_meta_icon                   = (array) json_decode( urldecode( $single_meta_icon ) );
				$single_meta_icon_arr['icon_type']  = ( isset( $single_meta_icon['type'] ) ) ? $single_meta_icon['type'] : 'icon-font';
				$single_meta_icon_arr['icon_class'] = ( isset( $single_meta_icon['icon-class'] ) ) ? $single_meta_icon['icon-class'] : '';
				$single_meta_icon_arr['icon_url']   = ( isset( $single_meta_icon['url'] ) ) ? $single_meta_icon['url'] : '';

				$single_meta['hide-title']      = ( isset( $mega_menu_meta['title-off'] ) ) ? (bool) ( $mega_menu_meta['title-off'] == 'yes' ) : false;
				$single_meta['megamenu-enable'] = ( isset( $mega_menu_meta['enabled'] ) ) ? (bool) ( $mega_menu_meta['enabled'] == 'yes' ) : false;
				$single_meta['new-row']         = ( isset( $mega_menu_meta['new-row'] ) ) ? (bool) ( $mega_menu_meta['new-row'] == 'yes' ) : false;
			}

			$menu_item_meta = get_post_meta( $item_id, 'fw:ext:mm:io:seosight-wp', true );
			if ( ! empty( $menu_item_meta ) ) {
				$single_meta['background-image']  = ( isset( $menu_item_meta['row']['bg-image']['url'] ) ) ? $menu_item_meta['row']['bg-image']['url'] : '';
				$single_meta['title_column_item'] = ( isset( $menu_item_meta['column']['title_column_item'] ) ) ? (bool) ( $menu_item_meta['column']['title_column_item'] == 'yes' ) : false;
			}

			if ( ! empty( $single_meta ) ) {
				update_post_meta( $item_id, 'seosight_menu_options', $single_meta );
				update_post_meta( $item_id, 'seosight_menu_icon', $single_meta_icon_arr );
			}
		}
	}
}

/**
 * Regenerate subscribe customizer options.
 */
function seosight_regenerate_subscribe_customizer_options() {
	$form_html_old       = seosight_get_option_value( 'section-subscribe-form/custom-form/html', '', array( 'name' => 'section-subscribe-form/custom-form/yes/html' ) );
	$name_field_show_old = seosight_get_option_value( 'section-subscribe-form/custom-form/show', false, array( 'name'     => 'section-subscribe-form/custom-form/no/name_field/show',
	                                                                                                           'bool_val' => '1'
	) );
	$name_field_swap_old = seosight_get_option_value( 'section-subscribe-form/custom-form/name_field_swap', false, array( 'name'     => 'section-subscribe-form/custom-form/no/name_field/true/name_field_swap',
	                                                                                                                      'bool_val' => '1'
	) );

	$all_options = get_option( 'seosight_customize_options' );
	if( isset($all_options['section-subscribe-form']['custom_form_html']) ){
		$all_options['section-subscribe-form']['custom_form_html'] = $form_html_old;
	}
	if( isset($all_options['section-subscribe-form']['show_form_name_field']) ){
		$all_options['section-subscribe-form']['show_form_name_field'] = $name_field_show_old;
	}
	if( isset($all_options['section-subscribe-form']['show_form_name_field_swap']) ){
		$all_options['section-subscribe-form']['show_form_name_field_swap'] = $name_field_swap_old;
	}

	update_option( 'seosight_customize_options', $all_options );
}

/**
 * Update email subscribers option.
 */
function seosight_update_email_subscribers_option() {
	if ( ! function_exists( 'es_subbox' ) ) {
		$all_options = get_option( 'seosight_customize_options' );
		if ( isset( $all_options['section-subscribe-form']['enable_email_subscribers'] ) ) {
			$all_options['section-subscribe-form']['enable_email_subscribers'] = 0;
		}
		update_option( 'seosight_customize_options', $all_options );
	}
}

/**
 * Update customizer options.
 */
function seosight_update_customizer_options() {
	$old_options = get_option( 'seosight_customize_options', array() );
	if( $old_options == '1' ){
		remove_theme_mod('seosight_customize_options');
	} elseif( !empty($old_options) ) {
		set_theme_mod( 'seosight_customize_options', $old_options );
	}
}

// Update lisence key
add_action('admin_init', 'seosight_update_license_key');
function seosight_update_license_key(){
    $meta_update = get_option( 'seosight_update_new_license' );
	if ( $meta_update != '1' ) {
        $cl_id = md5( wp_get_theme()->template );
        $lic = maybe_unserialize(get_option('appsero_'.$cl_id.'_manage_license'));

        if( isset($lic['status']) && isset($lic['key']) && $lic['status'] == 'activate' ){
            update_option("SeosightSEO_lic_Key", $lic['key']) || add_option("SeosightSEO_lic_Key", $lic['key']);
        }
		update_option( 'seosight_update_new_license', '1' );
    }
}

// Disables the block editor from managing widgets in the Gutenberg plugin.
add_filter( 'gutenberg_use_widgets_block_editor', '__return_false', 100 );

// Disables the block editor from managing widgets. renamed from wp_use_widgets_block_editor
add_filter( 'use_widgets_block_editor', '__return_false' );

/**
 * Add link for updating Google fonts
 */
function seosight_filter_fw_googleapis_webfonts_url() {
	return 'https://webfonts.crumina.net/';
}
add_filter('fw_googleapis_webfonts_url', 'seosight_filter_fw_googleapis_webfonts_url');

/**
 * REMOVE AUTHOR DESCRIPTION FROM STUNNING HEADER
 */

function seosight_modify_get_the_archive_description($description) { 
if ( is_author() ){
	$description = '';
}
    return $description; 
}
add_filter( 'get_the_archive_description', 'seosight_modify_get_the_archive_description', 10, 1 );

/**
 * Add new link for Unyson extension update
 */

if ( ! function_exists( 'seosight_filter_fw_filter_github_api_url' ) ) :
	function seosight_filter_fw_filter_github_api_url( $url ) {
		return 'https://api.github.com';
	}
endif;

add_filter( 'fw_github_api_url', 'seosight_filter_fw_filter_github_api_url', 999 );