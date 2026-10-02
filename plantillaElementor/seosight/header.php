<?php
/**
 * The header for our theme.
 *
 * This is the template that displays all of the <head> section and everything up until <div id="content">
 *
 * @link    https://developer.wordpress.org/themes/basics/template-files/#template-partials
 *
 * @package Seosight
 */
$website_preloader = seosight_get_option_value('website_preloader', false);
?>
    <!DOCTYPE html>
<html <?php language_attributes(); ?>>
    <head>
        <meta charset="<?php bloginfo( 'charset' ); ?>">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="profile" href="http://gmpg.org/xfn/11">
        <link rel="pingback" href="<?php bloginfo( 'pingback_url' ); ?>">
		<?php wp_head(); ?>
    </head>
<body <?php body_class(); ?>>
    <?php wp_body_open(); ?>
<?php if ( $website_preloader ) {
	$preloader_bg = get_template_directory_uri() . '/svg/preload.svg';
	echo seosight_html_tag( 'div', array(
		'id' => 'hellopreloader',
	), true );
} ?>
<?php if ( ! is_page_template( 'landing-template.php' ) ) {
// Options Variables
	$queried_object        = get_queried_object();
	$header_class          = $header_style = $custom_menu = $header_absolute = $header_animation = $sticky_atts = $sticky_pinned = $sticky_unpinned = $website_preloader = '';
	$header_class          = 'header navigation navigation-justified';
	$page_id               = get_the_ID();
	$show_aside            = seosight_get_option_value('aside-panel/value', false, array('bool_val' => 'yes'));
	$show_stunning         = seosight_get_option_value('stunning-show', true, array('name' => 'stunning-show/value','bool_val' => 'yes'));
	$show_top_bar          = seosight_get_option_value( 'sections-top-bar/status', false, array('bool_val' => 'show') );
	$sticky_header_desktop = seosight_get_option_value( 'sticky_header_desktop', true );
	$sticky_header_mobile  = seosight_get_option_value( 'sticky_header_mobile', false );
	if ( is_page() || is_singular( 'post' ) || is_singular( 'fw-portfolio' ) || is_singular( 'portfolio-kit' ) ) {
		$metabox_aside = seosight_get_option_value( 'aside-panel', 'default', array(), 'seosight_design_options', 'meta/' . $page_id );
		$show_aside = ( 'default' !== $metabox_aside ) ? $metabox_aside : $show_aside;
		if( $show_aside === 'no' ){
			$show_aside = false;
		}
		$customize_design_single = 'seosight_design_options';
		if ( is_singular( 'fw-portfolio' ) ) {
			$customize_design_single = 'seosight_fw_portfolio_design_customize';
		}
		$enable_customization = seosight_get_option_value( 'custom-header-enable', false, array('name'=>'custom-header/enable', 'bool_val' => 'yes'), $customize_design_single, 'meta/' . $page_id );
		if( $enable_customization ){
			$header_absolute = seosight_get_option_value( 'custom-header/header-absolute', false, array('name'=>'custom-header/yes/header-absolute'), $customize_design_single, 'meta/' . $page_id );
			$font_color = seosight_get_option_value( 'custom-header/header-color', '', array('name'=>'custom-header/yes/header-color'), $customize_design_single, 'meta/' . $page_id );
			if ( $header_absolute ) {
				$header_class .= ' header-absolute';
			}
			if ( ! empty( $font_color ) ) {
				$header_class .= ' header-color-inherit';
			}
			$custom_menu = seosight_get_option_value( 'custom-header/select_menu', '', array('name'=>'custom-header/yes/select_menu'), $customize_design_single, 'meta/' . $page_id );
		}

		$stunning_customization = seosight_get_option_value( 'custom-stunning-enable', false, array('name'=>'custom-stunning/enable', 'bool_val' => 'yes'), $customize_design_single, 'meta/' . $page_id );

		if ( $stunning_customization ) {
			$show_stunning = seosight_get_option_value( 'stunning-show', true, array('name'=>'custom-stunning/yes/stunning-show/value', 'bool_val' => 'yes'), $customize_design_single, 'meta/' . $page_id );
		}
	}

	if ( is_category() || (is_tax() && 'fw-portfolio-category' === $queried_object->taxonomy) ) {
		$stunning_page_id = $queried_object->term_id;
		$stunning_customization = seosight_get_option_value( 'custom-stunning-enable', false, array('name'=>'custom-stunning/enable', 'bool_val' => 'yes'), 'seosight_category', 'termmeta/' . $stunning_page_id );
		if ( $stunning_customization ) {
			$show_stunning = seosight_get_option_value( 'stunning-show', true, array('name'=>'custom-stunning/yes/stunning-show/value', 'bool_val' => 'yes'), 'seosight_category', 'termmeta/' . $stunning_page_id );
		}
	}

	set_query_var( 'show_stunning', $show_stunning );

	if ( $show_top_bar ) {
		$header_class .= ' header-top-bar';
	}

	if ( $sticky_header_desktop ) {
		$header_class .= ' sticky-top header-sticky-desktop';
	}

	if ( $sticky_header_mobile ) {
		$header_class .= ' sticky-top header-sticky-mobile';
	}

	$menu_args = array(
		'menu'           => $custom_menu,
		'menu_id'        => 'primary-menu',
		'menu_class'     => 'navigation-menu',
		'container'      => 'ul',
	);

	if ( has_nav_menu( 'primary' ) ) {
		$menu_args['theme_location'] = 'primary';
	}

	if ( defined( 'FW' ) && fw_ext('megamenu') ) {
		$menu_args['walker'] = new Seosight_Mega_Menu_Custom_Walker();
	} else {
		$menu_args['walker'] = new Seosight_Menu_Custom_Walker();
	} ?>

    <a class="skip-link screen-reader-text" href="#primary"><?php esc_html_e( 'Skip to content', 'seosight' ); ?></a>
    <!-- Header -->

    <header class="<?php echo esc_attr( $header_class ) ?>" id="site-header">
		<?php
		if ( $show_top_bar ) {
			get_template_part( 'template-parts/top-bar' );
		}
		?>
        <div class="container">

            <div class="navigation-header">
                <div class="navigation-logo">
                    <div class="logo">
						<?php seosight_logo(); ?>
                    </div>
                </div>
				<?php if ( $show_top_bar ) {
					echo '<div id="top-bar-js" class="top-bar-link"><svg viewBox="0 0 330 330">
  <path d="M165 0C74.019 0 0 74.02 0 165.001 0 255.982 74.019 330 165 330s165-74.018 165-164.999S255.981 0 165 0zm0 300c-74.44 0-135-60.56-135-134.999S90.56 30 165 30s135 60.562 135 135.001C300 239.44 239.439 300 165 300z"/>
  <path d="M164.998 70c-11.026 0-19.996 8.976-19.996 20.009 0 11.023 8.97 19.991 19.996 19.991 11.026 0 19.996-8.968 19.996-19.991 0-11.033-8.97-20.009-19.996-20.009zM165 140c-8.284 0-15 6.716-15 15v90c0 8.284 6.716 15 15 15 8.284 0 15-6.716 15-15v-90c0-8.284-6.716-15-15-15z"/>
</svg></div>';
				} ?>
                <div class="navigation-button-toggler">
                    <i class="hamburger-icon"></i>
                </div>
            </div>

            <div class="navigation-body">
                <div class="navigation-body-header">
                    <div class="navigation-logo">
                        <div class="logo">
							<?php seosight_logo(); ?>
                        </div>
                    </div>
                    <span class="navigation-body-close-button">&#10005;</span>
                </div>

                <div class="navigation-body-section navigation-additional-menu">
	                <?php wp_nav_menu( $menu_args ); ?>
					<?php seosight_additional_nav(); ?>
                </div>

				<?php
				if ( $show_aside ) {
					$custom_icon = seosight_get_option_value( 'aside-panel/icon', '', array('name' => 'aside-panel/yes/icon/url') );
					?>
                    <div class="user-menu open-overlay">
                        <a href="#" class="user-menu-content  js-open-aside">
							<?php if ( $custom_icon ) { ?>
                                <img src="<?php echo esc_attr( $custom_icon ); ?>" alt="Menu icon">
							<?php } else { ?>
                                <span></span>
                                <span></span>
                                <span></span>
							<?php } ?>
                        </a>
                    </div>
				<?php } ?>
            </div>

        </div>
    </header>

    <!-- ... End Header -->
	<?php
	if ( $show_aside ) {
		get_template_part( 'template-parts/panel', 'aside' );

	} ?>
    <div class="content-wrapper">

	<?php if ( $show_stunning && ! is_404() ) {

		get_template_part( 'template-parts/stunning', 'header' );
	}
}
