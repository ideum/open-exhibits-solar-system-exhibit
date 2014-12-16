<?xml version="1.0" encoding="UTF-8"?>
<GestureMarkupLanguage xmlns:gml="http://gestureworks.com/gml/version/1.0">
		
		<Gesture_set gesture_set_name="n-manipulate" >
		
			<Gesture id="n-drag" type="drag">
				<comment>The 'n-drag' gesture can be activated by any number of touch points. When a touch down is recognized on a touch object the position
				of the touch point is tracked. This change in the position of the touch point is mapped directly to the position of the touch object.</comment>			
				<match>
					<action>
						<initial>
							<cluster point_number="0" point_number_min="1" point_number_max="10" translation_threshold="0"/>
						</initial>
					</action>
				</match>	
				<analysis>
					<algorithm class="kinemetric" type="continuous">
						<library module="drag"/>
						<returns>
							<property id="drag_dx" result="dx"/>
							<property id="drag_dy" result="dy"/>
						</returns>
					</algorithm>
				</analysis>	
				<processing>
					<boundary_filter>
						   <property ref="dx" active="true" boundary_min="100" boundary_max="1720"/>
						   <property ref="dy" active="true" boundary_min="100" boundary_max="880"/>
					</boundary_filter>
				</processing> 
				<mapping>
					<update dispatch_type="continuous">
						<gesture_event  type="drag">
							<property ref="drag_dx" target="x" delta_threshold="true" delta_min="0.01" delta_max="100"/>
							<property ref="drag_dy" target="y" delta_threshold="true" delta_min="0.01" delta_max="100"/>
						</gesture_event>
					</update>
				</mapping>
			</Gesture>	
			
			<Gesture id="n-rotate" type="rotate">
				<comment>The 'n-rotate' gesture can be activated by any number of touch points between 2 and 10. When two or more touch points are recognized on a touch object the relative orientation
						of the touch points are tracked and grouped into a cluster. This change in the orientation of the cluster is mapped directly to the rotation of the touch object.</comment>
					
				<match>
					<action>
						<initial>
							<cluster point_number="0" point_number_min="2" point_number_max="10"/>
						</initial>
					</action>
				</match>
				<analysis>
					<algorithm class="kinemetric" type="continuous">
						<library module="rotate"/>
						<returns>
							<property id="rotate_dtheta" result="dtheta"/>
						</returns>
					</algorithm>
				</analysis>	
				<mapping>
					<update dispatch_type="continuous">
						<gesture_event type="rotate">
							<property ref="rotate_dtheta" target="rotate"/>
						</gesture_event>
					</update>
				</mapping>
			</Gesture>
					
			<Gesture id="n-scale" type="scale">					
				<comment>The 'n-scale' gesture can be activated by any number of touch points between 2 and 10. When two or more touch points are recognized on a touch object the relative separation
				of the touch points are tracked and grouped into a cluster. Changes in the separation of the cluster are mapped directly to the scale of the touch object.</comment>				
				<match>
					<action>
						<initial>
							<cluster point_number="0" point_number_min="2" point_number_max="10"/>
						</initial>
					</action>
				</match>
				<analysis>
					<algorithm class="kinemetric" type="continuous">
						<library module="scale"/>
						<returns>
							<property id="scale_dsx" result="ds"/>
							<property id="scale_dsy" result="ds"/>
						</returns>
					</algorithm>
				</analysis>
				<processing>
					<boundary_filter>
						   <property ref="scale_dsx" active="true" boundary_min="0.5" boundary_max="2"/>
						   <property ref="scale_dsy" active="true" boundary_min="0.5" boundary_max="2"/>
					</boundary_filter>
				</processing>
				<mapping>
					<update dispatch_type="continuous">
						<gesture_event  type="scale">
							<property ref="scale_dsx" target="scaleX"/>
							<property ref="scale_dsy" target="scaleY"/>
						</gesture_event>
					</update>
				</mapping>
			</Gesture>			
	
		</Gesture_set>
		
				
	<Gesture_set gesture_set_name="accessibility-gestures">
		
		<Gesture id="acc-3-finger-hold" type="hold">
			<match>
				<action>
					<initial>
						<point event_duration_min="500" translation_max="2"/>
						<cluster point_number="3" point_number_min="3" point_number_max="3"/>
					</initial>
				</action>
			</match>	
			<analysis>
				<algorithm class="temporalmetric" type="discrete">
					<library  module="hold"/>
					<returns>
						<property id="hold_x" result="x"/>
						<property id="hold_y" result="y"/>
						<property id="hold_n" result="n"/>
					</returns>
				</algorithm>
			</analysis>	
			<mapping>
				<update dispatch_type="discrete">
					<gesture_event  type="hold">
						<property ref="hold_x"/>
						<property ref="hold_y"/>
						<property ref="hold_n"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>	
		
		<Gesture id="acc-2-finger-hold" type="hold">
			<match>
				<action>
					<initial>
						<point event_duration_min="500" translation_max="2"/>
						<cluster point_number="2"/>
					</initial>
				</action>
			</match>	
			<analysis>
				<algorithm class="temporalmetric" type="discrete">
					<library  module="hold"/>
					<returns>
						<property id="hold_x" result="x"/>
						<property id="hold_y" result="y"/>
						<property id="hold_n" result="n"/>
					</returns>
				</algorithm>
			</analysis>	
			<mapping>
				<update dispatch_type="discrete">
					<gesture_event  type="hold">
						<property ref="hold_x"/>
						<property ref="hold_y"/>
						<property ref="hold_n"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>			
		
		<Gesture id="acc-1-finger-swipe-left" type="swipe">
			<match>
				<action>
					<initial>
						<cluster point_number="1"/>
						<event touch_event="gwTouchEnd"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm class="kinemetric" type="continuous">
					<library module="swipe" />
					<variables>
						<property id="swipe_dx" var="etm_ddx" return="etm_dx"/>
					</variables>
					<returns>
						<property id="swipe_dx" result="etm_dx"/>
					</returns>
				</algorithm>
			</analysis>
			<processing>
				<delta_filter>
						<property ref="swipe_dx" active="true" directional="true" delta_min="-20" delta_max="-100"/>	
				</delta_filter>
			</processing>
			<mapping>
				<update dispatch_type="discrete" dispatch_mode="cluster_remove" dispatch_reset="cluster_remove">
					<gesture_event  type="swipe">
						<property ref="swipe_dx" target=""/>
						
					</gesture_event>
				</update>
			</mapping>
		</Gesture>	
		
		<Gesture id="acc-2-finger-swipe" type="swipe">
			<match>
				<action>
					<initial>
						<cluster point_number="2"/>
						<event touch_event="gwTouchEnd"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm class="kinemetric" type="continuous">
					<library module="swipe" />					
					<variables>
						<property id="swipe_dx" var="etm_ddx" return="etm_dx" var_min="1"/>
						<property id="swipe_dy" var="etm_ddy" return="etm_dy" var_min="1"/>
					</variables>
					<returns>
						<property id="swipe_dx" result="etm_dx"/>
						<property id="swipe_dy" result="etm_dy"/>
					</returns>
				</algorithm>
			</analysis>	
			<processing>
				<delta_filter>
						<property ref="swipe_dx" active="true" delta_min="50" delta_max="100"/>	
						<property ref="swipe_dy" active="true" delta_min="50" delta_max="100"/>	
				</delta_filter>
			</processing>			
			<mapping>
				<update dispatch_type="discrete" dispatch_mode="cluster_remove" dispatch_reset="cluster_remove">
					<gesture_event  type="swipe">
						<property ref="swipe_dx" target=""/>
						<property ref="swipe_dy" target=""/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>		
		
		<Gesture id="acc-1-finger-swipe-right" type="swipe">
			<match>
				<action>
					<initial>
						<cluster point_number="1"/>
						<event touch_event="gwTouchEnd"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm class="kinemetric" type="continuous">
					<library module="swipe" />
					<variables>
						<property id="swipe_dx" var="etm_ddx" return="etm_dx"/>
					</variables>
					<returns>
						<property id="swipe_dx" result="etm_dx"/>
					</returns>
				</algorithm>
			</analysis>
			<processing>
				<delta_filter>
						<property ref="swipe_dx" active="true" directional="true" delta_min="20" delta_max="100"/>	
				</delta_filter>
			</processing>
			<mapping>
				<update dispatch_type="discrete" dispatch_mode="cluster_remove" dispatch_reset="cluster_remove">
					<gesture_event  type="swipe">
						<property ref="swipe_dx" target=""/>
						
					</gesture_event>
				</update>
			</mapping>
		</Gesture>	
		
		<Gesture id="acc-1-finger-tap" type="tap">
			<match>
				<action>
					<initial>
						<point event_duration_max=".2" translation_max="2"/>
						<cluster point_number="1"/>
						<event touch_event="gwTouchEnd"/>
					</initial>
				</action>
			</match>	
			<analysis>
				<algorithm class="temporalmetric" type="discrete">
					<library module="tap"/>
					<returns>
						<property id="tap_x" result="x"/>
						<property id="tap_y" result="y"/>
						<property id="tap_n" result="n"/>
					</returns>
				</algorithm>
			</analysis>	
			<mapping>
				<update dispatch_type="discrete" dispatch_mode="batch" dispatch_interval="200">
					<gesture_event  type="tap">
						<property ref="tap_x"/>
						<property ref="tap_y"/>
						<property ref="tap_n"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>	
		
		<Gesture id="acc-2-finger-tap" type="tap">
			<match>
				<action>
					<initial>
						<point event_duration_max=".2" translation_max="2"/>
						<cluster point_number="2"/>
						<event touch_event="gwTouchEnd"/>
					</initial>
				</action>
			</match>	
			<analysis>
				<algorithm class="temporalmetric" type="discrete">
					<library module="tap"/>
					<returns>
						<property id="tap_x" result="x"/>
						<property id="tap_y" result="y"/>
						<property id="tap_n" result="n"/>
					</returns>
				</algorithm>
			</analysis>	
			<mapping>
				<update dispatch_type="discrete" dispatch_mode="batch" dispatch_interval="200">
					<gesture_event  type="tap">
						<property ref="tap_x"/>
						<property ref="tap_y"/>
						<property ref="tap_n"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>																								

		<Gesture id="acc-1-finger-double-tap" type="double_tap">
		  <match>
			  <action>
				  <initial>
					  <point event_duration_max="300" interevent_duration_max="300" translation_max="20"/>
					  <cluster point_number="1"/>
					  <event gesture_event="tap"/>
				  </initial>
			  </action>
		  </match>	
		  <analysis>
			  <algorithm class="temporalmetric" type="discrete">
				  <library module="double_tap"/>
				  <returns>
					  <property id="double_tap_x" result="x"/>
					  <property id="double_tap_y" result="y"/>
					  <property id="double_tap_n" result="n"/>
				  </returns>
			  </algorithm>
		  </analysis>	
		  <mapping>
			  <update dispatch_type="discrete" dispatch_mode="batch" dispatch_interval="200">
				  <gesture_event  type="double_tap">
					  <property ref="double_tap_x"/>
					  <property ref="double_tap_y"/>
					  <property ref="double_tap_n"/>
				  </gesture_event>
			  </update>
		  </mapping>
		</Gesture>
	  
		<Gesture id="acc-h-stroke" type="stroke">
			<match>
				<action>
					<initial>
						<point path_pts="(x=0, y=0),(x=0.0024691358024691358, y=0.06172839506172839),(x=0.009876543209876543, y=0.12345679012345678),(x=0.014814814814814815, y=0.18518518518518517),(x=0.01728395061728395, y=0.24691358024691357),(x=0.019753086419753086, y=0.30864197530864196),(x=0.024691358024691357, y=0.37037037037037035),(x=0.02962962962962963, y=0.43209876543209874),(x=0.02962962962962963, y=0.49382716049382713),(x=0.03209876543209877, y=0.5555555555555556),(x=0.0345679012345679, y=0.6172839506172839),(x=0.0345679012345679, y=0.6790123456790124),(x=0.0345679012345679, y=0.7407407407407407),(x=0.03950617283950617, y=0.8024691358024691),(x=0.04197530864197531, y=0.8641975308641975),(x=0.046913580246913576, y=0.9259259259259259),(x=0.05432098765432099, y=0.9876543209876543),(x=0.07407407407407407, y=0.928395061728395),(x=0.08148148148148147, y=0.8666666666666667),(x=0.09382716049382715, y=0.8049382716049382),(x=0.1111111111111111, y=0.7432098765432099),(x=0.12839506172839507, y=0.6814814814814815),(x=0.15555555555555556, y=0.6246913580246913),(x=0.1876543209876543, y=0.5703703703703703),(x=0.2271604938271605, y=0.5209876543209876),(x=0.2765432098765432, y=0.48148148148148145),(x=0.3382716049382716, y=0.4666666666666667),(x=0.39753086419753086, y=0.48641975308641977),(x=0.4469135802469136, y=0.5259259259259259),(x=0.48148148148148145, y=0.5777777777777777),(x=0.508641975308642, y=0.6345679012345679),(x=0.5308641975308642, y=0.6938271604938272),(x=0.5481481481481482, y=0.7530864197530864),(x=0.5604938271604938, y=0.8148148148148148),(x=0.5703703703703703, y=0.8765432098765432),(x=0.5777777777777777, y=0.9382716049382716),(x=0.5851851851851851, y=1)"/>
						<cluster point_number="1"/>
						<event touchEvent="TouchEnd"/>
					</initial>
				</action>
			</match>
			<analysis>
				<algorithm class="vectormetric" type="continuous">
					<library module="stroke"/>
					<returns>
						<property id="stroke_x" result="x"/>
						<property id="stroke_y" result="y"/>
						<property id="stroke_prob" result="prob"/>
					</returns>
				</algorithm>
			</analysis>
			<mapping>
				<update dispatch_type="discrete" dispatch_mode="cluster_remove">
					<gesture_event type="stroke_letter">
						<property ref="stroke_x"/>
						<property ref="stroke_y"/>
						<property ref="stroke_prob"/>
					</gesture_event>
				</update>
			</mapping>
		</Gesture>  
	
	</Gesture_set>			
	
</GestureMarkupLanguage>