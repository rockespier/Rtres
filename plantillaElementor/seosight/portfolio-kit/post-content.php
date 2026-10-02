<?php
if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

$theKitClass = new PortfolioKitFrontend;

$gallery_images     = $theKitClass->get_option( get_the_ID(), 'portfolio_kit_gallery' );
$gallery_images_arr = array();
if ( $gallery_images != '' ) {
	$gallery_images_arr = explode( ",", $gallery_images );
}

$single_align_customizer = get_theme_mod( 'pk_settings_single_align', 'left' );
$single_likes            = get_theme_mod( 'pk_settings_single_likes', '1' );
$single_date             = get_theme_mod( 'pk_settings_single_date', '1' );

// Likes
$like_url_nonce = wp_create_nonce( 'pk-likes-nonce' );
$count_like     = get_post_meta( get_the_ID(), "_post_like_count", true );
$count_like     = $theKitClass->pk_format_count( intval( $count_like ) );
$already_liked  = ( $theKitClass->pk_already_liked( get_the_ID() ) ) ? 'liked' : '';

// Single post
$post_title   = get_the_title();
$custom_title = $theKitClass->get_option( get_the_ID(), 'portfolio_kit_title' );
if ( $custom_title != '' ) {
	$post_title = $custom_title;
}
$custom_desc  = $theKitClass->get_option( get_the_ID(), 'portfolio_kit_descr' );
$single_align = $theKitClass->get_option( get_the_ID(), 'portfolio_kit_single_align', $single_align_customizer );

$button = seosight_get_option_value( 'project-button', array(), array(), 'seosight_fw_portfolio', 'meta/' . get_the_ID() );
if ( ! isset( $button['background'] ) ) {
	$button['background'] = '';
}
?>

<div class="pk-single-cont section-padding bg-border-color <?php echo esc_attr( $single_align ); ?>">
    <div class="pk-single-cont-row pk-container">
        <div class="pk-single-image-cont">
			<?php
			$video = seosight_get_project_video();
			if ( $video ) {
				?>
                <div class="responsive-video">
					<?php seosight_render( $video ); ?>
                </div>
			<?php } elseif ( ! empty( $gallery_images_arr ) ) {
				?>
                <div class="pk-swiper-container">
                    <div class="swiper-wrapper">
						<?php
						foreach ( $gallery_images_arr as $thumbnail ) {
							?>
                            <div class="swiper-slide">
								<?php echo wp_get_attachment_image( $thumbnail, array( 700, 2000 ) ) ?>
                            </div>
						<?php } ?>
                    </div>
                    <div class="pk-swiper-pagination"></div>
                </div>
				<?php
			} elseif ( has_post_thumbnail() ) {
				the_post_thumbnail( array( 700, 2000 ) );
			}
			?>
        </div>
        <div class="pk-single-descr-cont">
            <div class="pk-single-meta project-meta">
				<?php if ( $single_likes || $single_date ) { ?>
					<?php if ( $single_date ) { ?>
                        <p class="pk-single-meta-time"><?php echo esc_html( get_the_date( 'F d, Y' ) ); ?></p>
					<?php } ?>
					<?php if ( $single_likes ) { ?>
                        <div class="pk-like-wrap sl-wrapper likes <?php echo esc_attr( $already_liked ); ?>"
                             data-post="<?php echo esc_attr( get_the_ID() ); ?>"
                             data-nonce="<?php echo esc_attr( $like_url_nonce ); ?>">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 70.004 70.004">
                                <path d="M1.812 23.46a2.117 2.117 0 0 0 2.4-1.789 17.061 17.061 0 0 1 4.849-9.658 17.158 17.158 0 0 1 15.832-4.659 17.103 17.103 0 0 1 7.017 3.331 21.44 21.44 0 0 0-3.849 7.209 2.118 2.118 0 0 0 4.048 1.237 17.241 17.241 0 0 1 4.28-7.118 17.2 17.2 0 0 1 10.852-4.998 2.116 2.116 0 0 0-.324-4.221 21.437 21.437 0 0 0-12.022 4.863 21.333 21.333 0 0 0-9.107-4.441A21.374 21.374 0 0 0 6.066 9.021 21.263 21.263 0 0 0 .023 21.059a2.117 2.117 0 0 0 1.789 2.401zM53.855 7.704c.55 0 1.101-.226 1.496-.621a2.15 2.15 0 0 0 .613-1.496c0-.558-.226-1.107-.613-1.503-.791-.783-2.208-.783-2.999 0a2.145 2.145 0 0 0-.621 1.503c0 .557.226 1.101.621 1.496a2.13 2.13 0 0 0 1.503.621zM6.077 39.331l.011.012 27.316 27.315c.413.413.955.62 1.497.62.542 0 1.083-.207 1.496-.62l8.204-8.203a2.115 2.115 0 1 0-2.993-2.993l-6.707 6.707L9.083 36.351l-.003-.003a17.093 17.093 0 0 1-3.802-5.73A2.116 2.116 0 1 0 1.353 32.2a21.28 21.28 0 0 0 4.722 7.128l.002.003zM52.539 49.641c.542 0 1.083-.207 1.496-.62l9.691-9.689a.027.027 0 0 1 .007-.008l.004-.004a21.301 21.301 0 0 0 6.268-15.165 21.301 21.301 0 0 0-6.292-15.156 2.116 2.116 0 1 0-2.991 2.995 17.087 17.087 0 0 1 5.049 12.163 17.093 17.093 0 0 1-5.03 12.171l-.005.007-.003.002-9.69 9.689a2.115 2.115 0 0 0 0 2.993c.413.415.954.622 1.496.622z"/>
                            </svg>
                            <span><?php echo esc_html( $count_like ); ?></span>
                        </div>
					<?php } ?>
				<?php } ?>
            </div>
            <div class="pk-single-descr">
                <h2 class="h1 heading-title"><?php echo esc_html( $post_title ); ?></h2>
				<?php
				if ( $custom_desc != '' ) {
					echo wpautop( $custom_desc );
				} else {
					echo wpautop( get_the_content() );
				}
				if ( ! empty( $button['label'] ) ) {
					$button_link = ( isset( $button['link'] ) ) ? $button['link'] : array();
					$link        = seosight_gen_link_for_shortcode( $button_link );
					?>
                    <a href="<?php echo esc_url( $link['link'] ) ?>"
                       style="background-color: <?php echo esc_attr( $button['background'] ? $button['background'] : '#2f2c2c' ); ?>;"
                       target="<?php echo esc_attr( $link['target'] ) ?>"
                       class="btn btn-medium btn-hover-shadow">
                        <span class="text"><?php echo esc_html( $button['label'] ) ?></span>
						<?php
						if ( '_blank' === $link['target'] ) {
							echo '<i class="seoicon-right-arrow"></i>';
						} else {
							echo '<span class="semicircle"></span>';
						}
						?>
                    </a>
				<?php } ?>
            </div>
        </div>
    </div>
</div>
					