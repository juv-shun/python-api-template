import aiomysql


class DB:
    async def init(
        self,
        host: str,
        user: str,
        password: str,
        db: str,
        port: int = 3306,
        autocommit: bool = True,
        timeout: int = 3,
    ) -> None:
        self.pool = await aiomysql.create_pool(
            host=host,
            port=port,
            user=user,
            password=password,
            db=db,
            autocommit=autocommit,
            connect_timeout=timeout,
        )

    async def close(self) -> None:
        self.pool.close()
        await self.pool.wait_closed()


client = DB()
