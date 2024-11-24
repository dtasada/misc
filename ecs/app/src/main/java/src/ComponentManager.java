package src;

import java.util.Map;

public class ComponentManager {
	/*
	 * Like:
	 * Map<Archetype, Map<ComponentType, Component>>
	 * Map<POSITION|VELOCITY, Map<VELOCITY, Component>>
	 */
	Map<Integer, Map<Integer, Component>> Components;

	public ComponentManager() {
		var c = Components.get(ComponentType.POSITION | ComponentType.VELOCITY).get(ComponentType.POSITION);

		this.addEntity(archetype, component);
	}

	public void addEntity(int archetype, int component) {
	}
}
