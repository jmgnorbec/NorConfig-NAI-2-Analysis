USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_user_perm]    Script Date: 2026-04-20 10:38:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_user_perm](
	[uid] [int] IDENTITY(10000,1) NOT NULL,
	[userid] [nvarchar](128) NOT NULL,
	[permission] [nvarchar](128) NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_user_perm] ADD  CONSTRAINT [DF_sys_user_perm_userid]  DEFAULT ('') FOR [userid]
GO

ALTER TABLE [dbo].[sys_user_perm] ADD  CONSTRAINT [DF_sys_user_perm_permission]  DEFAULT ('') FOR [permission]
GO

