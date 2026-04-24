USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_field_limitator]    Script Date: 2026-04-20 10:32:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_field_limitator](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[sys_field_ref_UID] [int] NOT NULL,
	[sys_limitator_UID] [int] NOT NULL,
 CONSTRAINT [sys_field_limitator_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_field_limitator]  WITH CHECK ADD  CONSTRAINT [sys_field_limitator_sys_field_ref_FK] FOREIGN KEY([sys_field_ref_UID])
REFERENCES [dbo].[sys_field_ref] ([UID])
GO

ALTER TABLE [dbo].[sys_field_limitator] CHECK CONSTRAINT [sys_field_limitator_sys_field_ref_FK]
GO

ALTER TABLE [dbo].[sys_field_limitator]  WITH CHECK ADD  CONSTRAINT [sys_field_limitator_sys_limitator_FK] FOREIGN KEY([sys_limitator_UID])
REFERENCES [dbo].[sys_limitator] ([UID])
GO

ALTER TABLE [dbo].[sys_field_limitator] CHECK CONSTRAINT [sys_field_limitator_sys_limitator_FK]
GO

