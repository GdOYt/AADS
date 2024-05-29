contract ReentryProtectorMixin {
    bool reentryProtector;
    function externalEnter() internal {
        if (reentryProtector) {
            throw;
        }
        reentryProtector = true;
    }
    function externalLeave() internal {
        reentryProtector = false;
    }
}
