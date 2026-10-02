<?php
/**
 * Template part for displaying page content in page.php.
 *
 * @link https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */
$show_stunning = get_query_var( 'show_stunning' );
$layout = seosight_sidebar_conf();
$pagebuilder_classes = seosight_geterate_page_classes( get_the_ID(), $layout );
$is_builder = $pagebuilder_classes['is_builder'];


$content_class = $is_builder ? 'entry-content' : 'entry-content-no-builder';

?>
<div id="page-<?php the_ID(); ?>">
	<?php if ( !$show_stunning && ! ( $is_builder ) ) { ?>
        <header class="entry-header">
			<?php the_title( '<h1 class="entry-title">', '</h1>' ); ?>
        </header><!-- .entry-header -->
	<?php } ?>
    <div class="<?php echo esc_attr( $content_class ) ?>">
		<?php
		the_content();

		wp_link_pages( array(
			'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'seosight' ),
			'after'  => '</div>',
		) );
		?>
    </div><!-- .entry-content -->

	<?php if ( get_edit_post_link() ) : ?>
        <footer class="entry-footer">
			<?php
			edit_post_link(
				sprintf(
				/* translators: %s: Name of current post */
					esc_html__( 'Edit %s', 'seosight' ),
					the_title( '<span class="screen-reader-text">"', '"</span>', false )
				),
				'<span class="edit-link">',
				'</span>'
			);
			?>
        </footer><!-- .entry-footer -->
	<?php endif; ?>
</div><!-- #post-## -->
