USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_limitator]    Script Date: 2026-04-20 10:33:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_limitator](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Nom] [nvarchar](60) NULL,
	[ConditionText] [nvarchar](max) NULL,
	[ConditionResult] [nvarchar](50) NULL,
	[sys_limitator_result_type_uid] [int] NULL,
 CONSTRAINT [sys_condition_group_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_limitator]  WITH CHECK ADD  CONSTRAINT [sys_limitator_sys_limitator_result_type_FK] FOREIGN KEY([sys_limitator_result_type_uid])
REFERENCES [dbo].[sys_limitator_result_type] ([uid])
GO

ALTER TABLE [dbo].[sys_limitator] CHECK CONSTRAINT [sys_limitator_sys_limitator_result_type_FK]
GO

