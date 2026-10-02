<?php

$ext_portfolio_instance = fw()->extensions->get( 'portfolio' );
$ext_portfolio_settings = $ext_portfolio_instance->get_settings();
$taxonomy               = $ext_portfolio_settings['taxonomy_name'];

$prev_post = get_adjacent_post( true, '', true, $taxonomy );
$next_post = get_adjacent_post( true, '', false, $taxonomy );


$default_project_page = seosight_get_option_value( 'folio-bottom-nav-page-select', '', array('name' => 'folio-bottom-nav/yes/page_select/0') );
$main_page_id = seosight_get_option_value( 'portfolio-page', $default_project_page, array('name' => 'portfolio-page/0') );
?>
<div class="container">
	<div class="pagination-arrow">
		<?php if ( is_a( $prev_post, 'WP_Post' ) ) { ?>
			<a href="<?php echo get_permalink( $prev_post->ID ); ?>" class="btn-nav btn-prev-wrap">
				<svg class="crumina-icon">
					<use xlink:href="#arrow-left"></use>
				</svg>
				<div class="btn-content">
				    <div class="btn-content-title"><?php esc_html_e( 'Previous Project', 'seosight' ) ?></div>
				    <p class="btn-content-subtitle"><?php echo get_the_title( $prev_post->ID ); ?></p>
			    </div>
			</a>
		<?php } ?>
		<?php if ( ! empty( $main_page_id ) ) { ?>
			<a href="<?php the_permalink( $main_page_id ) ?>" class="btn-nav all-project">
				<i class="seoicon-shapes"></i>
			</a>
		<?php } ?>
		<?php if ( is_a( $next_post, 'WP_Post' ) ) { ?>
			<a href="<?php echo get_permalink( $next_post->ID ); ?>" class="btn-nav btn-next-wrap">
				<div class="btn-content">
					<div class="btn-content-title"><?php esc_html_e( 'Next Project', 'seosight' ) ?></div>
					<p class="btn-content-subtitle"><?php echo get_the_title( $next_post->ID ); ?></p>
				</div>
				<svg class="crumina-icon">
					<use xlink:href="#arrow-right"></use>
				</svg>
			</a>
		<?php } ?>
	</div>
</div>