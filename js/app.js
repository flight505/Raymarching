import * as THREE from "three";
import fragment from "./shader/fragment.glsl";
import vertex from "./shader/vertex.glsl";
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import gsap from "gsap";
import GUI from "lil-gui";
import matcap from "../434343_9E9E9E_8C8C8C_848484-256px.png";
import matcap1 from "../242733_333A4D_3E4554_3C3B43-256px.png";



export default class Sketch {
  constructor(options) {
    this.scene = new THREE.Scene();

    this.container = options.dom;
    this.width = this.container.offsetWidth;
    this.height = this.container.offsetHeight;
    this.renderer = new THREE.WebGLRenderer();
    this.renderer.setPixelRatio(window.devicePixelRatio, 2);
    this.renderer.setSize(this.width, this.height);
    this.renderer.setClearColor(0xeeeeee, 1); 
    this.renderer.physicallyCorrectLights = true;
    this.renderer.outputEncoding = THREE.sRGBEncoding;

    this.container.appendChild(this.renderer.domElement);

    this.camera = new THREE.PerspectiveCamera(
      70,
      window.innerWidth / window.innerHeight,
      0.001,
      1000
    );

    let frustumSize = 1;
    let aspect = window.innerWidth / window.innerHeight;
    this.camera = new THREE.OrthographicCamera( frustumSize / - 2, frustumSize  / 2, frustumSize / 
    2, frustumSize / - 2, -1000, 1000 );
    this.camera.position.set(0, 0, 2);
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.time = 0;

    this.isPlaying = true;
    
    this.addObjects();
    this.resize();
    this.render();
    this.setupResize(); 
    this.mouseEvents();
    this.settings(); // enable for gui
  }

  mouseEvents() {
    this.mouse = new THREE.Vector2();
    document.addEventListener("mousemove", (e) => {
      this.mouse.x = e.pageX/this.width - 0.5;
      this.mouse.y = -e.pageY/this.height + 0.5;
    })
  }

  settings() {
    let that = this;
    this.settings = {
      progress: 0,
    };
    this.gui = new GUI();
    this.gui.add(this.settings, "progress", 0, 1, 0.01);
  }

  setupResize() {
    window.addEventListener("resize", this.resize.bind(this));
  }

  resize() {
    this.width = this.container.offsetWidth;
    this.height = this.container.offsetHeight;
    this.renderer.setSize(this.width, this.height);
    this.camera.aspect = this.width / this.height;
  
  

  // image cover
  this.imageAspect = 1;
  let a1; let a2;
  if (this.height / this.width > this.imageAspect) {
    a1 = (this.width / this.height) * this.imageAspect;
    a2 = 1;
  } else {
    a1 = 1;
    a2 = (this.height / this.width) * this.imageAspect;
  }
  this.material.uniforms.resolution.value.x = this.width;
  this.material.uniforms.resolution.value.y = this.height;
  this.material.uniforms.resolution.value.z = a1;
  this.material.uniforms.resolution.value.w = a2;

  this.camera.updateProjectionMatrix();
  }

  // add objects to scene here
  addObjects() {
    let that = this;
    this.material = new THREE.ShaderMaterial({
      extensions: {
        derivatives: "#extension GL_OES_standard_derivatives : enable"
      },
      side: THREE.DoubleSide,
      uniforms: {
        time: { type: "f", value: 0 },
        progress: { type: "f", value: 0 },
        mouse: { type: "v2", value: new THREE.Vector2(0.0) },
        matcap: { type: "t", value: new THREE.TextureLoader().load(matcap) },
        matcap1: { type: "t", value: new THREE.TextureLoader().load(matcap1) },
        resolution: { type: "v4", value: new THREE.Vector4() },
        uvRate1: {
          value: new THREE.Vector2(1, 1)
        }
      },
      // wireframe: true,
      // transparent: true,
      vertexShader: vertex,
      fragmentShader: fragment
    });

    this.geometry = new THREE.PlaneGeometry(1, 1, 1, 1); // width, height, widthSegments, heightSegments

    this.plane = new THREE.Mesh(this.geometry, this.material); // geometry, material
    this.scene.add(this.plane); // add test plane
  }

  stop() {
    this.isPlaying = false;
  }

  play() {
    if(!this.isPlaying){
      this.render()
      this.isPlaying = true;
    }
  }

  render() {
    if (!this.isPlaying) return;
    this.time += 0.07;
    this.material.uniforms.time.value = this.time; // update time uniform in shader material for animation effect on object in scene ( for example test plane)  
    this.material.uniforms.progress.value = this.settings.progress;
    if(this.mouse){
      this.material.uniforms.mouse.value = this.mouse
    } 
    // console.log(this.mouse);
    requestAnimationFrame(this.render.bind(this));
    this.renderer.render(this.scene, this.camera);
  }
}

new Sketch({
  dom: document.getElementById("container")
});
