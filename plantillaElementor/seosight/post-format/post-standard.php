<?php
/**
 * Template part for displaying posts.
 *
 * @link https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */
$show_excerpt      = get_query_var( 'post_excerpt', false );
$post_layout_width = get_query_var( 'post_layout' );
?>


<article id="post-<?php the_ID(); ?>" <?php post_class( 'post-standard' ); ?>>

    <?php if ( has_post_thumbnail() ) { ?>
        <div class="post-thumb-wrap">
            <div class="post-thumb">
                <a href="<?php the_permalink(); ?>">
                <?php if ( 'full' == $post_layout_width ) {
                    the_post_thumbnail( 'seosight-full' );
                } else {
                    the_post_thumbnail( 'post-thumbnails' );
                } ?>
                </a>
            </div>
        </div>
    <?php } ?>

    <div class="post__content">

        <?php seosight_post_author_avatar( get_the_author_meta( 'ID' ) ) ?>

        <div class="post__content-info">

            <?php the_title( '<h2 class="post__title entry-title"><a href="' . esc_url( get_permalink() ) . '" rel="bookmark">', '</a></h2>' ); ?>

            <div class="post-additional-info">
                <?php seosight_posted_on(); ?>
            </div>


            <div class="post__text">
                <?php
                if ( $show_excerpt ) {
                    the_excerpt();
                } else {
                    if ( ! has_excerpt() ) {
                        the_content();
                    } else {
                        the_excerpt();
                    }
                } ?>
            </div>

            <?php
            wp_link_pages( array(
                    'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'seosight' ),
                    'after'  => '</div>',
            ) );
            ?>

        </div>
    </div>

</article>