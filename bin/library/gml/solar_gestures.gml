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
		
	<Gesture id="acc-1-finger-swipe-left" type="swipe">
										<match>
											<action>
												<initial>
													<cluster point_number="1" point_number_min="1" point_number_max="1"/>
													<event touch_event="gwTouchEnd"/>
												</initial>
											</action>
										</match>
										<analysis>
											<algorithm class="kinemetric" type="continuous">
												<library module="swipe" />
												<variables>
													<property id="swipe_dx" var="etm_ddx" return="etm_dx" var_min="1"/>
												</variables>
												<returns>
													<property id="swipe_dx" result="etm_dx"/>
												</returns>
											</algorithm>
										</analysis>
										<processing>
											<delta_filter>
													<property ref="swipe_dx" active="true" directional="true" delta_min="-10" delta_max="-30"/>	
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

	<Gesture id="acc-1-finger-swipe-right" type="swipe">
										<match>
											<action>
												<initial>
													<cluster point_number="1" point_number_min="1" point_number_max="1"/>
													<event touch_event="gwTouchEnd"/>
												</initial>
											</action>
										</match>
										<analysis>
											<algorithm class="kinemetric" type="continuous">
												<library module="swipe" />
												<variables>
													<property id="swipe_dx" var="etm_ddx" return="etm_dx" var_min="1"/>
												</variables>
												<returns>
													<property id="swipe_dx" result="etm_dx"/>
												</returns>
											</algorithm>
										</analysis>
										<processing>
											<delta_filter>
													<property ref="swipe_dx" active="true" directional="true" delta_min="10" delta_max="30"/>	
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


	<Gesture id="acc-2-finger-swipe-left" type="swipe">
										<match>
											<action>
												<initial>
													<cluster point_number="2" />
													<event touch_event="gwTouchEnd"/>
												</initial>
											</action>
										</match>
										<analysis>
											<algorithm class="kinemetric" type="continuous">
												<library module="swipe" />
												<variables>
													<property id="swipe_dx" var="etm_ddx" return="etm_dx" var_min="1"/>
												</variables>
												<returns>
													<property id="swipe_dx" result="etm_dx"/>
												</returns>
											</algorithm>
										</analysis>
										<processing>
											<delta_filter>
													<property ref="swipe_dx" active="true" directional="true" delta_min="-10" delta_max="-30"/>	
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
	
	<Gesture id="acc-3-finger-tap" type="tap">
							<match>
								<action>
									<initial>
										<point event_duration_max="200" translation_max="10"/>
										<cluster point_number="3"/>
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
									<gesture_event type="tap">
										<property ref="tap_x"/>
										<property ref="tap_y"/>
										<property ref="tap_n"/>
									</gesture_event>
								</update>
							</mapping>
						</Gesture>
						
	<Gesture id="acc-4-finger-tap" type="tap">
							<match>
								<action>
									<initial>
										<point event_duration_max="200" translation_max="10"/>
										<cluster point_number="4"/>
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
									<gesture_event type="tap">
										<property ref="tap_x"/>
										<property ref="tap_y"/>
										<property ref="tap_n"/>
									</gesture_event>
								</update>
							</mapping>
						</Gesture>
	
	</Gesture_set>			
	
</GestureMarkupLanguage>