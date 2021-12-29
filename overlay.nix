self: super: { git = super.git.override { sendEmailSupport = true; }; }
