<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SujonController extends Controller
{

    public function all(Request $request)
    {
        try {
            $fromDate = $request->fromDate;
            $toDate = $request->toDate;
            $page = $request->input('page', 1);
            $perPage = $request->input('per_page', 10);

            $results = DB::select(
                'EXEC FindPriswebServiceWithDate @iFromDate = ?, @iToDate = ? ,@PageNumber = ?, @PageSize = ?',
                [$fromDate, $toDate, $page, $perPage]
            );

            return response()->json([
                'success' => 1,
                'data' => $results,
                'meta' => [
                    'current_page' => (int) $page,
                    'per_page' => (int) $perPage,
                ]
            ]);
        } catch (\Exception $ex) {
            return response()->json([
                'success' => 0,
                'data' => []
            ], 422);
        }
    }

    public function makbooth(Request $request)
    {
        try {
            $fromDate = $request->fromDate;
            $toDate = $request->toDate;
            $page = $request->input('page', 1);
            $perPage = $request->input('per_page', 10);

            $results = DB::select(
                'EXEC FindPriswebServiceMakboothWithDate @iFromDate = ?, @iToDate = ?,@PageNumber = ?, @PageSize = ?',
                [$fromDate, $toDate,$page, $perPage]
            );
            return response()->json([
                'success' => 1,
                'data' => $results,
                'meta' => [
                    'current_page' => (int) $page,
                    'per_page' => (int) $perPage,
                ]
            ]);
        } catch (\Exception $ex) {
            return response()->json([
                'success' => 0,
                'data' => []
            ], 422);
        }
    }

}
