<?php
/**
 * Template part for displaying aside widgets.
 *
 * @link    https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */

$show_logo  = seosight_get_option_value( 'aside-panel/logo', true, array('name' => 'aside-panel/yes/logo') );
$panel_text = seosight_get_option_value( 'aside-panel/text', '', array('name' => 'aside-panel/yes/text') );;


?>
<!-- Right-menu -->

<div class="popup right-menu">

	<div class="theme-custom-scroll">
		<div class="right-menu-wrap">
			<div class="user-menu-close js-close-aside">
				<a href="#" class="user-menu-content  js-clode-aside">
					<span></span>
					<span></span>
				</a>
			</div>
			<?php if ( $show_logo ) { ?>
				<div class="logo">
					<?php seosight_logo(); ?>
				</div>
			<?php } ?>

				<div class="text">
					<?php echo do_shortcode( wpautop( $panel_text ) ); ?>
				</div>

		</div>
		<?php dynamic_sidebar( 'sidebar-hidden' ); ?>
	</div>

</div>

<!-- ... End Right-menu -->