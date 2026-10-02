<?php
if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

$theKitClass = new PortfolioKit;

$gen_single_post_nav     = get_theme_mod( 'pk_settings_single_inner_nav', '1' );
$gen_single_primary_page = $theKitClass->get_option( 0, 'portfolio_kit_single_primary_page', '' );

$prev_post = get_adjacent_post( true, '', true, 'portfolio-kit-cat' );
$next_post = get_adjacent_post( true, '', false, 'portfolio-kit-cat' );
if ( $gen_single_post_nav ) {
	?>
    <div class="pk-pagination">
        <div class="pk-container">
            <div class="pk-pagination-arrow">
				<?php if ( is_a( $prev_post, 'WP_Post' ) ) { ?>
                    <a href="<?php echo get_permalink( $prev_post->ID ); ?>" class="pk-btn-nav pk-btn-prev-wrap">
                        <svg viewBox="122.9 388.2 184.3 85">
                            <path d="M124.1,431.3c0.1,2,1,3.8,2.4,5.2c0,0,0.1,0.1,0.1,0.1l34.1,34.1c1.6,1.6,3.7,2.5,5.9,2.5s4.3-0.9,5.9-2.4
                        c1.6-1.6,2.4-3.7,2.4-5.9s-0.9-3.9-2.4-5.5l-19.9-19.5h11.1c1.5,0,2.7-1.5,2.7-3c0-1.5-1.2-3-2.7-3h-17.6c-1.1,0-2.1,0.6-2.5,1.6
                        c-0.4,1-0.2,2.1,0.6,2.9l24.4,24.4c0.6,0.6,0.9,1.3,0.9,2.1s-0.3,1.6-0.9,2.1c-0.6,0.6-1.3,0.9-2.1,0.9s-1.6-0.3-2.1-0.9
                        l-34.2-34.2c0,0,0,0,0,0c-0.6-0.6-0.8-1.4-0.9-1.9c0,0,0,0,0,0c0-0.2,0-0.4,0-0.6c0.1-0.6,0.3-1.1,0.7-1.6c0-0.1,0.1-0.1,0.2-0.2
                        l34.1-34.1c0.6-0.6,1.3-0.9,2.1-0.9s1.6,0.3,2.1,0.9c0.6,0.6,0.9,1.3,0.9,2.1s-0.3,1.6-0.9,2.1l-24.4,24.4c-0.8,0.8-1,2-0.6,3
                        c0.4,1,1.4,1.7,2.5,1.7h125.7c1.5,0,2.7-1,2.7-2.5c0-1.5-1.2-2.5-2.7-2.5H152.6l19.9-20.1c1.6-1.6,2.4-3.8,2.4-6s-0.9-4.4-2.4-6
                        c-1.6-1.6-3.7-2.5-5.9-2.5s-4.3,0.9-5.9,2.4l-34.1,34.1c-0.2,0.2-0.3,0.3-0.5,0.5c-1.1,1.2-1.8,2.8-2,4.4
                        C124.1,430.2,124.1,430.8,124.1,431.3C124.1,431.3,124.1,431.3,124.1,431.3z"></path>
                            <path d="M283.3,427.9h14.2c1.7,0,3,1.3,3,3c0,1.7-1.4,3-3,3H175.1c-1.5,0-2.7,1.5-2.7,3c0,1.5,1.2,3,2.7,3h122.4
                        c4.6,0,8.4-3.9,8.4-8.5c0-4.6-3.8-8.5-8.4-8.5h-14.2c-1.5,0-2.7,1-2.7,2.5C280.7,426.9,281.8,427.9,283.3,427.9z"></path>
                        </svg>
                        <div class="pk-btn-content">
                            <div class="pk-btn-content-title"><?php esc_html_e( 'Previous Project', 'seosight' ) ?></div>
                            <p class="pk-btn-content-subtitle"><?php echo get_the_title( $prev_post->ID ); ?></p>
                        </div>
                    </a>
				<?php } ?>
				<?php if ( ! empty( $gen_single_primary_page ) ) { ?>
                    <a href="<?php the_permalink( $gen_single_primary_page ) ?>" class="pk-btn-nav pk-all-project ">
                        <i class="seoicon-shapes"></i>
                    </a>
				<?php } ?>
				<?php if ( is_a( $next_post, 'WP_Post' ) ) { ?>
                    <a href="<?php echo get_permalink( $next_post->ID ); ?>" class="pk-btn-nav pk-btn-next-wrap">
                        <div class="pk-btn-content">
                            <div class="pk-btn-content-title"><?php esc_html_e( 'Next Project', 'seosight' ) ?></div>
                            <p class="pk-btn-content-subtitle"><?php echo get_the_title( $next_post->ID ); ?></p>
                        </div>
                        <svg viewBox="122.9 388.2 184.3 85">
                            <path d="M305.9,430.2c-0.1-2-1-3.8-2.4-5.2c0,0-0.1-0.1-0.1-0.1l-34.1-34.1c-1.6-1.6-3.7-2.5-5.9-2.5c-2.2,0-4.3,0.9-5.9,2.4
                        c-1.6,1.6-2.4,3.7-2.4,5.9s0.9,4.1,2.4,5.7l19.9,19.6h-11.1c-1.5,0-2.7,1.5-2.7,3c0,1.5,1.2,3,2.7,3h17.6c1.1,0,2.1-0.7,2.5-1.7
                        c0.4-1,0.2-2.2-0.6-2.9l-24.4-24.5c-0.6-0.6-0.9-1.3-0.9-2.1s0.3-1.6,0.9-2.1c0.6-0.6,1.3-0.9,2.1-0.9c0.8,0,1.6,0.3,2.1,0.9
                        l34.2,34.2c0,0,0,0,0,0c0.6,0.6,0.8,1.4,0.9,1.9c0,0,0,0,0,0c0,0.2,0,0.4,0,0.6c-0.1,0.6-0.3,1.1-0.7,1.6c0,0.1-0.1,0.1-0.2,0.2
                        l-34.1,34.1c-0.6,0.6-1.3,0.9-2.1,0.9s-1.6-0.3-2.1-0.9c-0.6-0.6-0.9-1.3-0.9-2.1s0.3-1.6,0.9-2.1l24.4-24.4c0.8-0.8,1-1.9,0.6-2.9
                        c-0.4-1-1.4-1.6-2.5-1.6H158.1c-1.5,0-2.7,1-2.7,2.5c0,1.5,1.2,2.5,2.7,2.5h119.3l-19.9,20c-1.6,1.6-2.4,3.7-2.4,6s0.9,4.4,2.4,5.9
                        c1.6,1.6,3.7,2.5,5.9,2.5s4.3-0.9,5.9-2.4l34.1-34.1c0.2-0.2,0.3-0.3,0.5-0.5c1.1-1.2,1.8-2.8,2-4.4
                        C305.9,431.3,305.9,430.8,305.9,430.2C305.9,430.2,305.9,430.2,305.9,430.2z"></path>
                            <path d="M146.7,433.9h-14.2c-1.7,0-3-1.3-3-3c0-1.7,1.4-3,3-3h122.4c1.5,0,2.7-1.5,2.7-3c0-1.5-1.2-3-2.7-3H132.4
                        c-4.6,0-8.4,3.9-8.4,8.5c0,4.6,3.8,8.5,8.4,8.5h14.2c1.5,0,2.7-1,2.7-2.5C149.3,434.9,148.1,433.9,146.7,433.9z"></path>
                        </svg>
                    </a>
				<?php } ?>
            </div>
        </div>
    </div>
	<?php
}