package internalsdk

func Debug(tag, msg string) {
	log.Debugf("%s: %s", tag, msg)
}

func Error(tag, msg string) {
	log.Errorf("%s: %s", tag, msg)
}
