<?php
/**
 * Template part for displaying posts.
 *
 * @link https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */
$post_layout_width = get_query_var( 'post_layout' );

$blog_grid_type       = get_query_var( 'blog_grid_type' );
$post_extra_classes   = get_query_var( 'post_extra_classes' );
$post_extra_classes   = is_array( $post_extra_classes ) ? $post_extra_classes : array();

if ( is_sticky() ) {
    $post_extra_classes[] = 'sticky';
}
?>

<article id="post-<?php the_ID(); ?>" <?php post_class( implode( ' ', $post_extra_classes ) ); ?>>

    <?php if ( has_post_thumbnail() ) { ?>
        <div class="post-thumb-wrap">
            <div class="post-thumb">
                <a href="<?php the_permalink(); ?>">
                <?php
                if ( 'full' == $post_layout_width ) {
                    the_post_thumbnail( 'seosight-full-width' );
                } else {
                    the_post_thumbnail( 'post-thumbnails' );
                }
                ?>
                </a>
            </div>
        </div>
    <?php } ?>

    <div class="post__content">
        <?php if ( !has_post_thumbnail() && $blog_grid_type === 'blog-grid-main' ) { ?>
            <div class="post__no_thumb"><img loading="lazy" src="<?php echo esc_url( get_template_directory_uri() . '/img/no-image.svg' ); ?>" alt="<?php esc_attr_e( 'No image', 'seosight' ); ?>"></div>
        <?php } ?>
        <div class="post__content-info">
            <?php seosight_grid_title_with_post_meta(); ?>
	        <?php
		        $excerpt = get_the_excerpt();
		        if ( ! has_excerpt() ) {
			        $excerpt = get_the_content();
		        } if ( !empty($excerpt) ){
                ?>
                <div class="post__text">
                    <p><?php echo esc_html( wp_trim_words( $excerpt, 16 ) ); ?></p>
                </div>
	        <?php } ?>
        </div>

        <div class="post__author author vcard">
            <?php seosight_grid_post_author(); ?>
        </div>

        <?php
        wp_link_pages( array(
            'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'seosight' ),
            'after'  => '</div>',
        ) );
        ?>
    </div>

</article>