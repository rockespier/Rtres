<?php
$img_width  = 574;
$img_height = intval( $img_width * 0.75 );

$the_query = seosight_get_related_posts( 'post_tag', 'category', 9 );
?>
<?php if ( $the_query ) { ?>
<!-- Recent case -->
    <div class="recent-case align-center">
            <div class="row related-projects-title">
                <div class="col-lg-8 col-lg-offset-2">
                    <div class="heading align-center">
                        <h4 class="heading-title"><?php esc_html_e( "Related posts", "seosight" ); ?></h4>
                        <div class="heading-decoration">
                            <span class="first"></span>
                            <span class="second"></span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="case-item-wrap row crumina-module-slider">
                <div class="swiper-container pagination-bottom" data-show-items="2" data-scroll-items="2">
                    <div class="swiper-wrapper">
						<?php
						while ( $the_query->have_posts() ) : $the_query->the_post(); ?>
                        <div class="col-lg-6 col-md-6 col-sm-6 col-xs-12 swiper-slide">
							<?php get_template_part( 'post-format/post', 'related' );
							?>
                        </div>
						<?php endwhile; ?>
                    </div>
                    <!-- If we need pagination -->
                    <div class="swiper-pagination"></div>
                </div>
            </div>

    </div>
<!-- End Recent case -->
<?php }