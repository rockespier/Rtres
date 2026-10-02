<?php
/**
 * Template Name: Portfolio
 */
get_header();

$portfolio_post_type = get_option( 'pk_main_post_type', 'fw-portfolio' );

$the_query              = seosight_custom_loop($portfolio_post_type);
$ext_portfolio_settings = apply_filters( 'fw_portfolio_settings', array(
	'post_type'     => 'fw-portfolio',
	'slug'          => 'project',
	'taxonomy_slug' => 'portfolio',
	'taxonomy_name' => 'fw-portfolio-category'
) );

$taxonomy   = $ext_portfolio_settings['taxonomy_name'];
$term       = get_term_by( 'slug', get_query_var( 'term' ), $taxonomy );
$term_id    = ( ! empty( $term->term_id ) ) ? $term->term_id : 0;
$categories = seosight_portfolio_get_listing_categories( $term_id );

$listing_classes = seosight_portfolio_get_sort_classes( $the_query->posts, $categories );
$loop_data       = array(
	'settings'        => apply_filters( 'fw_portfolio_settings', array(
		'post_type'     => 'fw-portfolio',
		'slug'          => 'project',
		'taxonomy_slug' => 'portfolio',
		'taxonomy_name' => 'fw-portfolio-category'
	) ),
	'categories'      => $categories,
	'listing_classes' => $listing_classes
);
set_query_var( 'fw_portfolio_loop_data', $loop_data );

$layout     = seosight_sidebar_conf();

$sort_panel = seosight_get_option_value( 'sorting_panel', true, array('name' => 'sorting_panel/value', 'bool_val' => 'yes'), 'seosight_portfolio_page_options', 'meta/' . get_the_ID() );
$sort_type = seosight_get_option_value( 'sorting_panel_action', '', array('name' => 'sorting_panel/yes/action'), 'seosight_portfolio_page_options', 'meta/' . get_the_ID() );
$pagination = seosight_get_option_value( 'pagination_type', '', array('name' => 'pagination_type'), 'seosight_portfolio_page_options', 'meta/' . get_the_ID() );

$sort_wrapper_class = 'sort' == $sort_type ? 'sorting-menu' : '';

?>
	<!-- Case Item -->
<div id="primary" class="container">
	<div class="row section-padding">
		<div class="<?php echo esc_attr( $layout['content-classes'] ) ?>">
			<main id="main" class="site-main" >
				<div id="page-content" class="ovh">
					<?php while ( have_posts() ) : the_post();
						the_content();
					endwhile; ?>
				</div>
				<?php if ( $the_query->have_posts() ) { ?>
			<?php if ( ! empty( $categories ) && $sort_panel ) : ?>
				<ul class="cat-list align-center <?php echo esc_attr( $sort_wrapper_class ) ?>">
					<?php if ( 'sort' === $sort_type ) { ?>
						<li class="cat-list__item active" data-filter="*"><a href="#" class=""><?php esc_html_e( 'All Projects', 'seosight' ); ?></a></li>
						<?php foreach ( $categories as $category ) : ?>
							<li class="cat-list__item" data-filter=".category_<?php echo esc_attr( $category->term_id ) ?>"><a href="#" class=""><?php echo esc_html( $category->name ); ?></a></li>
						<?php endforeach; ?>
					<?php } else {

						$terms = get_terms( $taxonomy, array( 'hide_empty' => true ) );
						foreach ( $terms as $term ) : ?>
							<?php $active = ( $term->term_id == $term_id ) ? 'active' : ''; ?>
							<li class="cat-list__item <?php echo esc_attr( $active ) ?>"><a href="<?php echo esc_url( get_term_link( $term->slug, $taxonomy ) ) ?>"><?php echo esc_html( $term->name ); ?></a>
							</li>
						<?php endforeach; ?>
					<?php } ?>
				</ul>
				<?php endif; ?>
				<div class="row sorting-container" data-layout="packery" id="portfolio-loop">
					<?php while ( $the_query->have_posts() ) : $the_query->the_post();
						get_template_part( 'template-parts/portfolio/loop', 'item' );
					endwhile;
					?>
				</div>

				<?php if ( 'loadmore' === $pagination ) {
					seosight_ajax_loadmore( $the_query, $container_id = 'portfolio-loop' );
				} else {
					seosight_paging_nav( $the_query );
				} ?>
				<?php } ?>
			</main><!-- #main -->
		</div>
		<?php if ( 'full' !== $layout['position'] ) { ?>
		<div class="<?php echo esc_attr( $layout['sidebar-classes'] ) ?>">
			<?php get_sidebar(); ?>
		</div>
		<?php } ?>
	</div><!-- #row -->
</div><!-- #primary -->
<!-- End Case Item -->
<?php
unset( $ext_portfolio_instance );
unset( $ext_portfolio_settings );
set_query_var( 'fw_portfolio_loop_data', '' );

get_footer();