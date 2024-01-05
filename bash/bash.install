post_upgrade() {
	grep -qe '^/bin/bash$' etc/shells || echo '/bin/bash' >> etc/shells
	grep -qe '^/usr/bin/bash$' etc/shells || echo '/usr/bin/bash' >> etc/shells
	grep -qe '^/bin/rbash$' etc/shells || echo '/bin/rbash' >> etc/shells
	grep -qe '^/usr/bin/rbash$' etc/shells || echo '/usr/bin/rbash' >> etc/shells
	grep -qe '^/bin/sh$' etc/shells || echo '/bin/sh' >> etc/shells
	grep -qe '^/usr/bin/sh$' etc/shells || echo '/usr/bin/sh' >> etc/shells
}

