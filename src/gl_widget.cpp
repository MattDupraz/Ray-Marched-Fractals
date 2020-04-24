#include "gl_widget.h"

#include <QMatrix4x4>

enum Attribute { VERTEX = 0, TEX_COORD };

void GLWidget::initializeGL() {
	prog.addShaderFromSourceFile(QOpenGLShader::Vertex,
			":/vertex_shader.glsl");
	prog.addShaderFromSourceFile(QOpenGLShader::Fragment,
			":/fragment_shader.glsl");

	prog.bindAttributeLocation("vertex", VERTEX);	
	prog.bindAttributeLocation("tex_coord", TEX_COORD);	

	prog.link();
	prog.bind();

	prog.setUniformValue("aspect_ratio", float(1.0));
	prog.setUniformValue("camera_transform", QMatrix4x4());

	startTimer(20);
	timer.restart();
}

void GLWidget::timerEvent(QTimerEvent* event) {
	Q_UNUSED(event);
	double dt = timer.restart() / 1000.0;	

	camera_yaw += 30.0 * dt;
	camera_pitch += 57.5 * dt;

	update();
}


void GLWidget::resizeGL(int width, int height) {
	glViewport(0, 0, width, height);	
	prog.setUniformValue("aspect_ratio", float(width)/float(height));
}

void GLWidget::paintGL() {
	QMatrix4x4 camera_transform;
	camera_transform.rotate(camera_pitch, 1.0, 0.0, 0.0);
	camera_transform.rotate(camera_yaw, 0.0, 1.0, 0.0);
	camera_transform.translate(camera_pos);
	prog.setUniformValue("camera_transform", camera_transform);

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glBegin(GL_TRIANGLES);
	{
		prog.setAttributeValue(TEX_COORD, 0.0, 0.0);
		prog.setAttributeValue(VERTEX, -1.0, -1.0);
		prog.setAttributeValue(TEX_COORD, 0.0, 1.0);
		prog.setAttributeValue(VERTEX, -1.0,  1.0);
		prog.setAttributeValue(TEX_COORD, 1.0, 1.0);
		prog.setAttributeValue(VERTEX,  1.0,  1.0);

		prog.setAttributeValue(TEX_COORD, 1.0, 1.0);
		prog.setAttributeValue(VERTEX,  1.0,  1.0);
		prog.setAttributeValue(TEX_COORD, 1.0, 0.0);
		prog.setAttributeValue(VERTEX,  1.0, -1.0);
		prog.setAttributeValue(TEX_COORD, 0.0, 0.0);
		prog.setAttributeValue(VERTEX, -1.0, -1.0);
	}
	glEnd();
}
