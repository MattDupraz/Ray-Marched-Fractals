#pragma once

#include <QOpenGLWidget>
#include <QOpenGLShaderProgram>
#include <QVector3D>
#include <QTimerEvent>
#include <QElapsedTimer>

class GLWidget : public QOpenGLWidget {
	public:
	private:
		virtual void initializeGL() override;
		virtual void resizeGL(int width, int height) override;
		virtual void paintGL() override;
		virtual void timerEvent(QTimerEvent* event) override;
		
		QOpenGLShaderProgram prog;
		QElapsedTimer timer;
		
		float camera_pitch = 0.0;
		float camera_yaw = 0.0;
		QVector3D camera_pos = QVector3D(0.0, 0.0, -4.0);
};
