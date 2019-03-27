//#include <jni.h>

__attribute__((visibility("default"))) jint Java_Loader_getpid(JNIEnv *env, jobject jobj) {
    jint pid = getpid();
    return pid;
}

__attribute__((visibility("default"))) void Java_Loader_jnimain(JNIEnv *env, jobject jobj) {
    prepare_memory();
}
