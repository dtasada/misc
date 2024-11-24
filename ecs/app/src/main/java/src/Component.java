package src;

import java.awt.Image;

public class Component {
	ComponentType type;

	public class Position extends Component {
		public float x, y;
	}

	public class Velocity extends Component {
		public float x, y;
	}

	public class Sprite extends Component {
		public Image image;
	}
}
