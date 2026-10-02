<?php
/**
 * Template part for displaying aside widgets.
 *
 * @link    https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */
$queried_object = get_queried_object();
$current_page_id = get_the_ID();
$shop_page_id  = null;
if (function_exists('wc_get_page_id')){
	$shop_page_id = wc_get_page_id('shop');
	$page_id = is_shop() || is_product() || is_product_taxonomy() ? $shop_page_id : $current_page_id;
}
else {
	$page_id = $current_page_id;
}

$style            = $class            = '';

$bg_type = seosight_get_option_value( 'stunning_bg_type', 'image_bg', array('name' => 'stunning_bg_type/selected') );
$bg_overlay = seosight_get_option_value( 'stunning_overlay', '' );
$text_color = seosight_get_option_value( 'stunning_text_color', '' );
$hide_title = seosight_get_option_value( 'stunning_hide_title', true, array('bool_val' => 'yes') );
$hide_breadcrumbs = seosight_get_option_value( 'stunning_hide_breadcrumbs', true, array('bool_val' => 'yes') );

$video_bg_conf = array();
$video_type = seosight_get_option_value( 'stunning_bg_video/stunning_bg_cover', 'oembed', array('name' => 'stunning_bg_type/video_bg/selected/source') );
$video_bg_conf[ 'poster' ] = seosight_get_option_value( 'stunning_bg_video/placeholder', '', array('name' => 'stunning_bg_type/video_bg/placeholder/url') );

if ( $video_type === 'oembed' ) {
	$video_bg_conf[ 'video' ] = seosight_get_option_value( 'stunning_bg_video/stunning_bg_cover_oembed', '', array('name' => 'stunning_bg_type/video_bg/selected/oembed/source') );
	$video_bg_conf[ 'autoPlay' ] = true;
}

if ( $video_type === 'self' ) {
	$video_bg_conf[ 'mp4' ]  = seosight_get_option_value( 'stunning_bg_video/stunning_bg_cover_self_mp4', '', array('name' => 'stunning_bg_type/video_bg/selected/self/mp4/url') );
	$video_bg_conf[ 'webm' ] = seosight_get_option_value( 'stunning_bg_video/stunning_bg_cover_self_webm', '', array('name' => 'stunning_bg_type/video_bg/selected/self/webm/url') );
	$video_bg_conf[ 'ogg' ]  = seosight_get_option_value( 'stunning_bg_video/stunning_bg_cover_self_ogg', '', array('name' => 'stunning_bg_type/video_bg/selected/self/ogg/url') );
}

$class = 'stunning-header-custom';

$stunning_meta_type = 'meta';
$stunning_page_id = $page_id;
$stunning_source = 'seosight_design_options';
if ( is_singular( 'fw-portfolio' ) ) {
	$stunning_source = 'seosight_fw_portfolio_design_customize';
}
if ( is_category() || (is_tax() && 'fw-portfolio-category' === $queried_object->taxonomy) ) {
	$stunning_meta_type = 'termmeta';
	$stunning_page_id = $queried_object->term_id;
	$stunning_source = 'seosight_category';
}

$enable_customization = seosight_get_option_value( 'custom-stunning-enable', false, array('name'=>'custom-stunning/enable', 'bool_val' => 'yes'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
if ( $enable_customization ) {
	$custom_title = seosight_get_option_value( 'custom-stunning/custom-title', '', array('name'=>'custom-stunning/yes/stunning-show/yes/custom-title'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
	$hide_title = seosight_get_option_value( 'custom-stunning/stunning_hide_title', 'default', array('name'=>'custom-stunning/yes/stunning-show/yes/stunning_hide_title'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
	$hide_breadcrumbs = seosight_get_option_value( 'custom-stunning/stunning_hide_breadcrumbs', 'default', array('name'=>'custom-stunning/yes/stunning-show/yes/stunning_hide_breadcrumbs'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
	if( $hide_title === 'yes' ){
		$hide_title = false;
	}
	if( $hide_breadcrumbs === 'yes' ){
		$hide_breadcrumbs = false;
	}

	$bg_type = seosight_get_option_value( 'custom-stunning/stunning_bg_type', $bg_type, array('name' => 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/selected'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
	$bg_overlay = seosight_get_option_value( 'custom-stunning/stunning_overlay', $bg_overlay, array('name'=>'custom-stunning/yes/stunning-show/yes/stunning_overlay'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
	$text_color = seosight_get_option_value( 'custom-stunning/stunning_text_color', $text_color, array('name' => 'custom-stunning/yes/stunning-show/yes/stunning_text_color'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );

	$video_bg_conf = array();
	$video_type = seosight_get_option_value( 'custom-stunning/stunning_bg_video/stunning_bg_cover', $video_type, array('name' => 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/image_bg/stunning_bg_cover'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
	$video_bg_conf[ 'poster' ] = seosight_get_option_value( 'custom-stunning/stunning_bg_video/placeholder', '', array('name' => 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/placeholder/url'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
	if ( $video_type === 'oembed' ) {
		$video_bg_conf[ 'video' ] = seosight_get_option_value( 'custom-stunning/stunning_bg_video/stunning_bg_cover_oembed', '', array('name' => 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/selected/oembed/source'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
		$video_bg_conf[ 'autoPlay' ] = true;
	}

	if ( $video_type === 'self' ) {
		$video_bg_conf[ 'mp4' ]  = seosight_get_option_value( 'custom-stunning/stunning_bg_video/stunning_bg_cover_self_mp4', '', array('name' => 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/selected/self/mp4/url'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
		$video_bg_conf[ 'webm' ] = seosight_get_option_value( 'custom-stunning/stunning_bg_video/stunning_bg_cover_self_webm', '', array('name' => 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/selected/self/webm/url'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
		$video_bg_conf[ 'ogg' ]  = seosight_get_option_value( 'custom-stunning/stunning_bg_video/stunning_bg_cover_self_ogg', '', array('name' => 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/selected/self/ogg/url'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
	}
}

if ( !empty( $text_color ) ) {
	$class .= ' font-color-custom ';
}

?>
<!-- Stunning header -->
<div id="stunning-header" class="stunning-header stunning-header-bg-gray <?php echo esc_attr( $class ) ?>">
	<?php
	if ( !empty( $bg_overlay ) && function_exists( 'seosight_html_tag' ) ) {
		echo seosight_html_tag( 'div', array(
			'class' => 'overlay',
			'style' => 'background-color:' . esc_attr( $bg_overlay )
		), true );
	}
	
	if ( !empty( $video_type ) && $bg_type === 'video_bg' ) {
		echo seosight_bg_video_layer( $video_bg_conf );
	}
	?>
    <div class="stunning-header-content">
		<?php
		if ( $hide_title ) {
			if ( ! empty( $custom_title ) ) {
				echo '<h1 class="stunning-header-title">' . esc_html( $custom_title ) . '</h1>';
			} elseif ( is_home() ) {
				?>
                <h1 class="stunning-header-title"><?php esc_html_e( 'Latest posts', 'seosight' ); ?></h1>
			<?php } elseif ( is_search() ) { ?>
                <span class="stunning-header-title h1 page-title">
                    <?php printf( esc_html__( 'Search Results for: %s', 'seosight' ), '<h1 class="stunning-header-title">"' . get_search_query() . '"</h1>' ); ?>
                </span>
				<?php
			} elseif ( function_exists( 'is_shop' ) && is_shop() ) {
				if ( is_shop() ) {
					?>
                    <h2 class="stunning-header-title h1"><?php echo get_the_title( $page_id ); ?></h2>
				<?php } elseif ( is_product() ) { ?>
                    <h2 class="stunning-header-title h1"><?php esc_html_e( 'Product Details', 'seosight' ); ?></h2>
					<?php
				} elseif ( is_cart() || is_checkout() || is_checkout_pay_page() ) {
					the_title( '<h1 class="stunning-header-title h1">', '</h1>' );
				}
			} elseif ( is_page() || is_singular() ) {
				the_title( '<h1 class="stunning-header-title h1">', '</h1>' );
			} else {
				the_archive_title( '<h1 class="stunning-header-title">', '</h1>' );
			}
		}
		if ( function_exists( 'fw_ext_breadcrumbs' ) && ! is_home() && ! is_front_page() && ! is_search() && $hide_breadcrumbs ) {
			fw_ext_breadcrumbs( '<span class="breadcrumbs-separator"><i class="seoicon-right-arrow"></i></span>' );
		}
		if ( $page_id !== $shop_page_id ) {
			the_archive_description( '<div class="category-description">', '</div>' );
		}
		?>
    </div>
</div>
<!-- End Stunning header -->
