<?php

$img_width  = 574;
$img_height = intval( $img_width * 0.75 );

$ext_portfolio_settings = apply_filters( 'fw_portfolio_settings', array(
	'post_type'     => 'fw-portfolio',
	'slug'          => 'project',
	'taxonomy_slug' => 'portfolio',
	'taxonomy_name' => 'fw-portfolio-category'
) );

$the_query = seosight_get_related_posts( false, $ext_portfolio_settings['taxonomy_name'], 9 );
?>
<?php if ( $the_query ) { ?>
<!-- Recent case -->
<div class="container">
    <div class="recent-case align-center">
            <div class="row related-projects-title">
                <div class="col-lg-8 col-lg-offset-2">
                    <div class="heading align-center mb30">
                        <h4 class="h2 heading-title"><?php esc_html_e( "Related projects", "seosight" ); ?></h4>
                        <div class="heading-decoration">
                            <span class="first"></span>
                            <span class="second"></span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="case-item-wrap row crumina-module-slider">
                <div class="swiper-container pagination-bottom" data-show-items="3" data-scroll-items="3">
                    <div class="swiper-wrapper">
						<?php
						while ( $the_query->have_posts() ) : $the_query->the_post();
							$open_link    = seosight_get_option_value( 'open-item', 'default', array(), 'seosight_fw_portfolio_page_open', 'meta/' . get_the_ID() );
							$thumbnail_id = get_post_thumbnail_id();
							if ( isset( $open_link ) && $open_link === 'lightbox' ) {
								$permalink  = wp_get_attachment_image_src( $thumbnail_id, 'full' );
								$permalink  = $permalink[0];
								$link_class = 'js-zoom-image';
							} else {
								$permalink  = get_the_permalink();
								$link_class = '';
							}
							?>
                            <div class="col-lg-4 col-md-4 col-sm-6 col-xs-12 crumina-case-item swiper-slide">
                                <div class="case-item__thumb mouseover lightbox shadow animation-disabled">
									<?php
									if ( ! empty( $thumbnail_id ) ) {
										$thumbnail       = get_post( $thumbnail_id );
										$image           = seosight_resize( $thumbnail->ID, $img_width, $img_height, true );
										$thumbnail_title = $thumbnail->post_title;
									} else {
										$image           = fw()->extensions->get( 'portfolio' )->locate_URI( '/static/img/no-photo.jpg' );
										$thumbnail_title = $image;
									} ?>
                                    <img loading="lazy" src="<?php echo esc_url( $image ) ?>"
                                         width="<?php echo esc_attr( $img_width ) ?>"
                                         height="<?php echo esc_attr( $img_height ) ?>"
                                         alt="<?php echo esc_attr( $thumbnail_title ) ?>"/>
                                </div>
                                <h6 class="case-item__title"><?php the_title(); ?></h6>
                                <a href="<?php echo esc_url( $permalink ) ?>"
                                   class="full-block-link <?php echo esc_attr( $link_class ) ?>"></a>
                            </div>
						<?php
						endwhile; ?>
                    </div>
                    <!-- If we need pagination -->
                    <div class="swiper-pagination"></div>
                </div>
            </div>

    </div>
</div>
<!-- End Recent case -->
<?php }