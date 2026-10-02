<?php
/**
 * The template for displaying all pages
 *
 * This is the template that displays all pages by default.
 * Please note that this is the WordPress construct of pages and that
 * other 'pages' on your WordPress site will use a different template.
 */

$show_share_custom = $show_navigation_custom = $show_related_custom = '';

$post_id = get_the_ID();
$layout = seosight_sidebar_conf();
/* Elements Customization options */

// Options value

$media_align = seosight_get_option_value( 'thumbnail-align', 'left' );


$show_share      = seosight_get_option_value( 'folio-share-show', false, array('bool_val' => 'yes') );
$show_navigation = seosight_get_option_value( 'folio-bottom-nav', true, array('name' => 'folio-bottom-nav/post-navigation', 'bool_val' => 'yes') );
$show_related    = seosight_get_option_value( 'folio-related-show', false, array('name' => 'folio-related-show/value', 'bool_val' => 'yes') );
$media_align_custom = seosight_get_option_value('thumbnail-align', 'default', array(), 'seosight_fw_portfolio_design_customize', 'meta/' . get_the_ID() );
$media_align = ( ! empty( $media_align_custom ) && 'default' !== $media_align_custom ) ? $media_align_custom : $media_align;

// Metabox value
$enable_customization = seosight_get_option_value('custom-description-enable', false, array('name' => 'custom-description/enable', 'bool_val' => 'yes'), 'seosight_fw_portfolio_design_customize', 'meta/' . get_the_ID() );
if ( $enable_customization ) {
    $show_share_custom      = seosight_get_option_value('folio-share-show', 'default', array('name' => 'custom-description/yes/folio-share-show'), 'seosight_fw_portfolio_design_customize', 'meta/' . get_the_ID() );
    $show_navigation_custom = seosight_get_option_value('folio-navigation-show', 'default', array('name' => 'custom-description/yes/folio-navigation-show'), 'seosight_fw_portfolio_design_customize', 'meta/' . get_the_ID() );
    $show_related_custom    = seosight_get_option_value('folio-related-show', 'default', array('name' => 'custom-description/yes/folio-related-show'), 'seosight_fw_portfolio_design_customize', 'meta/' . get_the_ID() );

    // End value
    $show_share      = ( ! empty( $show_share_custom ) && 'default' !== $show_share_custom ) ? $show_share_custom : $show_share;
    $show_navigation = ( ! empty( $show_navigation_custom ) && 'default' !== $show_navigation_custom ) ? $show_navigation_custom : $show_navigation;
    $show_related    = ( ! empty( $show_related_custom ) && 'default' !== $show_related_custom ) ? $show_related_custom : $show_related;
        
    if($show_share === 'no'){
        $show_share = false;
    }
    if($show_navigation === 'no'){
        $show_navigation = false;
    }
    if($show_related === 'no'){
        $show_related = false;
    }
}

$page_wrapper_classes = seosight_geterate_page_classes( $post_id, $layout );
$container_width = $page_wrapper_classes['container_width'];
$padding_class   = $page_wrapper_classes['padding_class'];

get_header(); ?>
    <div id="primary">
        <?php get_template_part( 'template-parts/project', $media_align ); ?>
<?php while ( have_posts() ) : the_post(); ?>
        <div class="<?php echo esc_attr( $container_width ) ?>">
            <div class="row <?php echo esc_attr( $padding_class ) ?>">
                <div class="<?php echo esc_attr( $layout['content-classes'] ) ?>">
                    <main id="main" class="site-main" >
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
    <?php endwhile; ?>
    </div><!-- #primary -->
<?php if ( $show_share ) {
    get_template_part( 'template-parts/share', 'panel' );
}
if ( $show_navigation ) {
    get_template_part( 'template-parts/portfolio', 'navigation' );
}
if ( $show_related ) {
    get_template_part( 'template-parts/related', 'slider' );
}

get_footer();
