<?php

use App\Http\Controllers\SujonController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::get('sujon/all', [SujonController::class, 'all']);
Route::get('sujon/makbooth', [SujonController::class, 'makbooth']);
