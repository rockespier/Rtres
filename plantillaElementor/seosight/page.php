<?php
/**
 * The template for displaying all pages.
 *
 * This is the template that displays all pages by default.
 * Please note that this is the WordPress construct of pages
 * and that other 'pages' on your WordPress site may use a
 * different template.
 *
 * @link https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */

get_header();
$layout = seosight_sidebar_conf();
$page_wrapper_classes = seosight_geterate_page_classes( get_the_ID(), $layout );

$main_class = 'full' !== $layout['position'] ? 'site-main content-main-sidebar' : 'site-main content-main-full';
$container_width = $page_wrapper_classes['container_width'];
$padding_class   = $page_wrapper_classes['padding_class'];
?>
	<div id="primary" class="<?php echo esc_attr( $container_width ) ?>">
		<div class="row <?php echo esc_attr( $padding_class ) ?>">
			<div class="<?php echo esc_attr( $layout['content-classes'] ) ?>">
				<main id="main" class="<?php echo esc_attr( $main_class ) ?>" >

					<?php
					while ( have_posts() ) : the_post();

						get_template_part( 'template-parts/content', 'page' );

						// If comments are open or we have at least one comment, load up the comment template.
						if ( comments_open() || get_comments_number() ) :
							comments_template();
						endif;

					endwhile; // End of the loop.
					?>

				</main><!-- #main -->
			</div>
			<?php if ( 'full' !== $layout['position'] ) { ?>
				<div class="<?php echo esc_attr( $layout['sidebar-classes'] ) ?>">
					<?php get_sidebar(); ?>
				</div>
			<?php } ?>
		</div><!-- #row -->
	</div><!-- #primary -->
<?php
get_footer();
