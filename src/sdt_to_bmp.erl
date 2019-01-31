-module(sdt_to_bmp).

%% API exports
-export([main/1]).

%%====================================================================
%% API functions
%%====================================================================

-define(BMP_HEADER(FileSz, Offset),
        $B:8,$M:8,
        FileSz:32/little,
        0:16, 0:16,
        Offset:32/little).

-define(BMP_INFO(HSize,Width,Height,Planes,BitCount,Compression,
                 ImageSize,XRes,YRes,ColorsUsed,ImportantColors),
        HSize:32/little,
        Width:32/little,
        Height:32/little,
        Planes:16/little,
        BitCount:16/little,
        Compression:32/little,
        ImageSize:32/little,
        XRes:32/little,
        YRes:32/little,
        ColorsUsed:32/little,
        ImportantColors:32/little).

%% escript Entry point
main([FileName, OutDir]) ->
    io:format("Args: ~p~n", [FileName]),
    {ok, Contents} =file:read_file(FileName),
    InfoHeader = <<?BMP_INFO(40, 1024, 1024, 1, 24, 0, 0, 1024, 1024, 0, 0)>>,
    FileSize = (1024*1024 + 54),
    BmpHeader = <<?BMP_HEADER(FileSize, 54)>>,
    Data = triple(erlang:binary_to_list(Contents), []),
    DataBin = erlang:list_to_binary(Data),
    Result = erlang:list_to_binary([BmpHeader, InfoHeader, DataBin ]),
    BaseName = filename:basename(FileName),
    OutFileName = (string:replace(BaseName, ".sdt", ".bmp")),
    OutDirFile = OutDir ++ (OutFileName),
    ok = file:write_file(OutDirFile, Result),
    erlang:halt(0).


triple([], Acc) -> lists:reverse(Acc);
triple([F | Rest], Acc) ->
    triple(Rest, [F, F, F | Acc]).

%%====================================================================
%% Internal functions
%%====================================================================
