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
	
</GestureMarkupLanguage>