<?php

$post_id     = get_the_ID();
$layout      = seosight_sidebar_conf();
/* Elements Customization options */

$page_wrapper_classes = seosight_geterate_page_classes( $post_id, $layout );
$container_width      = $page_wrapper_classes['container_width'];
$padding_class        = $page_wrapper_classes['padding_class'];
$is_builder = $page_wrapper_classes['is_builder'];

get_header(); ?>

<?php get_template_part('portfolio-kit/post','content'); ?>

<?php while ( have_posts() ) : the_post(); ?>
	<?php if ( ! empty( get_the_content() ) || $is_builder ) { ?>
        <div id="primary">
            <div class="<?php echo esc_attr( $container_width ) ?>">
                <div class="row <?php echo esc_attr( $padding_class ) ?>">
                    <div class="<?php echo esc_attr( $layout['content-classes'] ) ?>">
                        <main id="main" class="site-main">
							<?php the_content(); ?>
                        </main><!-- #main -->
                    </div>
					<?php if ( 'full' !== $layout['position'] ) { ?>
                        <div class="<?php echo esc_attr( $layout['sidebar-classes'] ) ?>">
							<?php get_sidebar(); ?>
                        </div>
					<?php } ?>
                </div><!-- #row -->
            </div>
        </div><!-- #primary -->
	<?php } ?>
<?php endwhile; ?>
<?php get_template_part( 'template-parts/related', 'slider' ); ?>
<?php
get_footer();